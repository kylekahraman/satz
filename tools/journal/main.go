// Journal is a standalone cross-platform starter and entry helper for Satz.
package main

import (
	"archive/zip"
	"bufio"
	"context"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"sort"
	"strconv"
	"strings"
	"time"
	"unicode"

	"golang.org/x/term"
)

//go:embed runtime templates
var assets embed.FS

const entriesMarker = "// --- end entries ---"

var errCancelled = errors.New("cancelled")
var version = "development"

type settings struct {
	Path     string          `json:"path,omitempty"` // Legacy single-journal setting.
	Journals []journalRecord `json:"journals,omitempty"`
	Editor   string          `json:"editor,omitempty"`
}

type journalRecord struct {
	Name    string `json:"name"`
	Path    string `json:"path"`
	Details string `json:"-"`
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		if errors.Is(err, errCancelled) {
			fmt.Println("  Cancelled.")
			return
		}
		fmt.Fprintln(os.Stderr, "journal:", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 || args[0] == "new" {
		newArgs := args
		if len(args) > 0 {
			newArgs = args[1:]
		}
		path, editor, err := parseNewArgs(newArgs)
		if err != nil {
			return err
		}
		return newEntry(path, editor)
	}
	switch args[0] {
	case "init":
		if len(args) != 2 {
			return errors.New("usage: journal init PATH")
		}
		path, err := initProject(args[1])
		if err != nil {
			return err
		}
		if err := rememberProject(path); err != nil {
			return err
		}
		fmt.Printf("Journal created and selected: %s\nOpen the folder in VS Code, open main.typ, then run Typst: Preview.\n", path)
		return nil
	case "use":
		if len(args) != 2 {
			return errors.New("usage: journal use PATH")
		}
		path, err := filepath.Abs(args[1])
		if err != nil {
			return err
		}
		if _, err := registrationPath(path); err != nil {
			return fmt.Errorf("cannot connect journal: %w", err)
		}
		if err := rememberProject(path); err != nil {
			return err
		}
		fmt.Println("Journal selected:", path)
		return nil
	case "reconnect":
		if len(args) != 3 {
			return errors.New("usage: journal reconnect OLD_PATH NEW_PATH")
		}
		if err := reconnectProject(args[1], args[2]); err != nil {
			return err
		}
		fmt.Println("Journal reconnected:", args[2])
		return nil
	case "journals":
		if len(args) > 2 || (len(args) == 2 && args[1] != "--details") {
			return errors.New("usage: journal journals [--details]")
		}
		path, err := chooseJournalDetails(bufio.NewReader(os.Stdin), os.Stdout, true, len(args) == 2)
		if err != nil {
			return err
		}
		fmt.Println("Selected journal:", path)
		return nil
	case "forget":
		if len(args) != 2 {
			return errors.New("usage: journal forget PATH")
		}
		if err := forgetProject(args[1]); err != nil {
			return err
		}
		fmt.Println("Removed from journal list; files remain in", args[1])
		return nil
	case "rename":
		if len(args) != 3 {
			return errors.New("usage: journal rename PATH NAME")
		}
		if err := renameProject(args[1], args[2]); err != nil {
			return err
		}
		fmt.Println("Journal display name updated:", args[2])
		return nil
	case "check":
		if len(args) > 2 {
			return errors.New("usage: journal check [PATH]")
		}
		path := ""
		if len(args) == 2 {
			path = args[1]
		}
		project, err := loadProject(path)
		if err != nil {
			return err
		}
		issues := checkJournal(project)
		if len(issues) > 0 {
			return fmt.Errorf("journal check for %s:\n  - %s", project, strings.Join(issues, "\n  - "))
		}
		fmt.Println("Journal check passed:", project)
		return nil
	case "editor":
		if len(args) > 2 {
			return errors.New("usage: journal editor [COMMAND|--clear]")
		}
		if len(args) == 1 {
			registry, err := loadRegistry()
			if err != nil {
				return err
			}
			if registry.Editor == "" {
				fmt.Println("No editor configured; using VISUAL, EDITOR, or VS Code.")
			} else {
				fmt.Println("Configured editor:", registry.Editor)
			}
			return nil
		}
		value := args[1]
		if value == "--clear" {
			value = ""
		}
		if err := setEditorPreference(value); err != nil {
			return err
		}
		if value == "" {
			fmt.Println("Editor preference cleared.")
		} else {
			fmt.Println("Configured editor:", value)
		}
		return nil
	case "open", "template", "template-default":
		kind, path := "", ""
		if args[0] == "open" {
			if len(args) > 2 {
				return errors.New("usage: journal open [PATH]")
			}
			if len(args) == 2 {
				path = args[1]
			}
		} else {
			if len(args) < 2 || len(args) > 3 {
				return fmt.Errorf("usage: journal %s KIND [PATH]", args[0])
			}
			kind = normalizeKind(args[1])
			if !validKind(kind) {
				return errors.New("template kind must be meeting, session, or notes")
			}
			if len(args) == 3 {
				path = args[2]
			}
		}
		project, err := loadProject(path)
		if err != nil {
			return err
		}
		if _, err := registrationPath(project); err != nil {
			return err
		}
		if args[0] == "template-default" {
			file, err := writeDefaultTemplate(project, kind)
			if err != nil {
				return err
			}
			fmt.Println("Default template copy created:", file)
			return nil
		}
		target := ""
		if args[0] == "template" {
			target = filepath.Join(project, "templates", kind+".typ")
			if info, err := os.Stat(target); err != nil || info.IsDir() {
				return fmt.Errorf("template not found: %s", target)
			}
		}
		editor, err := preferredEditor("")
		if err != nil {
			return err
		}
		opened, err := openEditor(project, target, editor)
		if err != nil {
			return fmt.Errorf("could not open editor: %w", err)
		}
		if !opened {
			if target == "" {
				target = project
			}
			fmt.Println("Open this path in your editor:", target)
			fmt.Println("Set an editor with journal editor 'COMMAND', or choose Editor on the home screen.")
		}
		return nil
	case "entries", "search", "recent":
		query, path := "", ""
		if args[0] == "search" {
			if len(args) < 2 || len(args) > 3 || strings.TrimSpace(args[1]) == "" {
				return errors.New("usage: journal search QUERY [PATH]")
			}
			query = args[1]
			if len(args) == 3 {
				path = args[2]
			}
		} else {
			if len(args) > 2 {
				return fmt.Errorf("usage: journal %s [PATH]", args[0])
			}
			if len(args) == 2 {
				path = args[1]
			}
		}
		project, err := loadProject(path)
		if err != nil {
			return err
		}
		entries, err := discoverEntries(project, query)
		if err != nil {
			return err
		}
		if len(entries) == 0 {
			fmt.Println("No matching entries in", project)
			return nil
		}
		if args[0] == "recent" {
			editor, err := preferredEditor("")
			if err != nil {
				return err
			}
			opened, err := openEditor(project, entries[0].Path, editor)
			if err != nil {
				return err
			}
			if !opened {
				fmt.Println("Open this entry in your editor:", entries[0].Path)
			}
			return nil
		}
		fmt.Printf("Entries in %s\n", project)
		for _, entry := range entries {
			fmt.Printf("  %s  %s\n", entry.Modified.Local().Format("2006-01-02 15:04"), filepath.Base(entry.Path))
		}
		return nil
	case "update-satz":
		return errors.New("runtime updates are unavailable until a safe backup and recovery workflow is implemented; no files were changed")
	case "starter-zip":
		if len(args) != 2 {
			return errors.New("usage: journal starter-zip OUTPUT.zip")
		}
		return writeStarterZip(args[1])
	case "help", "--help", "-h":
		printHelp()
		return nil
	case "version", "--version":
		fmt.Println("Satz Journal", version)
		return nil
	case "shortcut":
		if len(args) != 2 {
			return errors.New("usage: journal shortcut OUTPUT")
		}
		executable, err := os.Executable()
		if err != nil {
			return err
		}
		if err := writeShortcut(args[1], executable, runtime.GOOS); err != nil {
			return err
		}
		fmt.Println("Shortcut created:", args[1])
		return nil
	default:
		return fmt.Errorf("unknown command %q; run `journal help`", args[0])
	}
}

func printHelp() {
	fmt.Println(`Satz Journal — a standalone helper for your Typst research journal

Commands:
  journal init PATH             Create a ready-to-edit journal and select it
  journal                       Prompt for and open a new entry
  journal new [PATH]            Add an entry to a selected or named journal
  journal use PATH              Select a different journal folder
  journal journals [--details]  Manage journals; optionally show entry counts
  journal reconnect OLD NEW     Update a moved journal's registered path
  journal forget PATH           Remove a journal from the list, keeping its files
  journal rename PATH NAME      Change its name in the journal list
  journal check [PATH]          Check journal setup without changing files
  journal editor [COMMAND]      Show or set editor; --clear uses environment
  journal open [PATH]           Open the journal folder in your editor
  journal template KIND [PATH]  Open an entry template in your editor
  journal template-default KIND [PATH]  Save a separate default template copy
  journal entries [PATH]        List entries by last modification
  journal search QUERY [PATH]   Find entries containing text
  journal recent [PATH]         Open the last modified entry
  journal version               Show the executable version
  journal shortcut OUTPUT       Create a desktop launcher at OUTPUT
  journal starter-zip OUTPUT   Build a shareable starter ZIP (maintainers)

Use --editor "PATH [ARGS...]" with ` + "`journal new`" + ` to select an editor. The helper
never invokes a shell and never changes shell startup files.`)
}

func parseNewArgs(args []string) (path, editor string, err error) {
	for i := 0; i < len(args); i++ {
		arg := args[i]
		if arg == "--editor" {
			if i+1 == len(args) {
				return "", "", errors.New("--editor needs an executable path or command")
			}
			i++
			editor = args[i]
			continue
		}
		if strings.HasPrefix(arg, "--editor=") {
			editor = strings.TrimPrefix(arg, "--editor=")
			continue
		}
		if strings.HasPrefix(arg, "-") {
			return "", "", fmt.Errorf("unknown option %q", arg)
		}
		if path != "" {
			return "", "", errors.New("usage: journal new [PATH] [--editor COMMAND]")
		}
		path = arg
	}
	return path, editor, nil
}

// normalizeInputPath expands a leading home-directory marker before making a
// path absolute. Shells normally do this for command-line arguments, but paths
// entered at interactive prompts do not pass through a shell.
func normalizeInputPath(path string) (string, error) {
	if path == "~" || strings.HasPrefix(path, "~/") || (runtime.GOOS == "windows" && strings.HasPrefix(path, `~\`)) {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		path = filepath.Join(home, strings.TrimLeft(path[1:], `/\`))
	}
	return filepath.Abs(path)
}

func initProject(input string) (string, error) {
	destination, err := normalizeInputPath(input)
	if err != nil {
		return "", err
	}
	if info, err := os.Stat(destination); err == nil {
		if !info.IsDir() {
			return "", fmt.Errorf("destination is not a directory: %s", destination)
		}
		entries, err := os.ReadDir(destination)
		if err != nil {
			return "", err
		}
		if len(entries) != 0 {
			return "", fmt.Errorf("destination already exists and is not empty: %s", destination)
		}
	} else if !errors.Is(err, os.ErrNotExist) {
		return "", err
	}
	for _, dir := range []string{"entries", "templates", ".vscode"} {
		if err := os.MkdirAll(filepath.Join(destination, dir), 0o755); err != nil {
			return "", err
		}
	}
	for _, kind := range []string{"meeting", "session", "notes"} {
		if err := os.WriteFile(filepath.Join(destination, "templates", kind+".typ"), []byte(scaffold(kind)), 0o644); err != nil {
			return "", err
		}
	}

	today := time.Now()
	entryPath := filepath.ToSlash(filepath.Join("entries", today.Format("2006-01-02")+"-getting-started.typ"))
	for _, name := range []string{"config.typ", "setup.typ", "cover.typ", "main.typ"} {
		if err := copyAsset("templates/"+name, filepath.Join(destination, name)); err != nil {
			return "", err
		}
	}
	first, err := fs.ReadFile(assets, "templates/first-entry.typ")
	if err != nil {
		return "", err
	}
	first = []byte(strings.ReplaceAll(string(first), "{{DATE_DISPLAY}}", today.Format("Monday, 02/01/2006")))
	if err := os.WriteFile(filepath.Join(destination, filepath.FromSlash(entryPath)), first, 0o644); err != nil {
		return "", err
	}
	entryList := "// The journal helper adds new entries above the end marker.\n#include \"" + entryPath + "\"\n" + entriesMarker + "\n"
	if err := os.WriteFile(filepath.Join(destination, "journal-entries.typ"), []byte(entryList), 0o644); err != nil {
		return "", err
	}
	if err := copyAsset("templates/extensions.json", filepath.Join(destination, ".vscode", "extensions.json")); err != nil {
		return "", err
	}
	if err := os.WriteFile(filepath.Join(destination, ".gitignore"), []byte("*.pdf\n.satz-journal.lock\n"), 0o644); err != nil {
		return "", err
	}
	readme := `# Your Satz research journal

## Get started

1. Install [Visual Studio Code](https://code.visualstudio.com/) and the [Tinymist Typst extension](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist).
2. Open this folder in VS Code, then open ` + "`main.typ`" + `.
3. Open the command palette and choose **Typst: Preview**.

Edit ` + "`config.typ`" + ` to personalize the cover and journal style. Change the title, subtitle, author, theme, cover layout, and paper size there. Available themes include ` + "`neutral`" + `, ` + "`soft-jade`" + `, ` + "`soft-slate`" + `, ` + "`warm-editorial`" + `, ` + "`plum`" + `, and ` + "`soft-rose`" + `. Add new entries under ` + "`entries/`" + ` and include them in ` + "`journal-entries.typ`" + ` above its end marker. Keep the include of ` + "`journal-entries.typ`" + ` in ` + "`main.typ`" + ` so the entries appear in the journal.

Edit the files in ` + "`templates/`" + ` to change future entry content. The helper supplies each entry's title, date, and keywords. For customized templates, install the Typst CLI (https://typst.app/open-source/#download) so the helper can check the entry before saving it. The original templates work without the CLI.

To keep the complete journal in the preview while editing another file, open ` + "`main.typ`" + ` and run **Typst: Pin Main**. The ` + "`_satz/`" + ` folder contains the Satz source used by this journal, so no Satz package installation is needed. Its revision is recorded in ` + "`_satz/VERSION.txt`" + `.
`
	if err := os.WriteFile(filepath.Join(destination, "README.md"), []byte(readme), 0o644); err != nil {
		return "", err
	}
	if err := copyEmbeddedDir("runtime", filepath.Join(destination, "_satz")); err != nil {
		return "", err
	}
	return destination, nil
}

func copyAsset(source, destination string) error {
	data, err := fs.ReadFile(assets, source)
	if err != nil {
		return err
	}
	return os.WriteFile(destination, data, 0o644)
}

func copyEmbeddedDir(source, destination string) error {
	return fs.WalkDir(assets, source, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		relative := strings.TrimPrefix(path, source)
		relative = strings.TrimPrefix(relative, "/")
		output := destination
		if relative != "" {
			output = filepath.Join(destination, filepath.FromSlash(relative))
		}
		if entry.IsDir() {
			return os.MkdirAll(output, 0o755)
		}
		data, err := fs.ReadFile(assets, path)
		if err != nil {
			return err
		}
		return os.WriteFile(output, data, 0o644)
	})
}

func isJournal(path string) bool {
	info, err := os.Stat(filepath.Join(path, "main.typ"))
	if err != nil || info.IsDir() {
		return false
	}
	info, err = os.Stat(filepath.Join(path, "entries"))
	return err == nil && info.IsDir()
}

func checkJournal(project string) []string {
	var issues []string
	list, err := registrationPath(project)
	if err != nil {
		issues = append(issues, err.Error())
	} else if data, err := os.ReadFile(list); err != nil {
		issues = append(issues, fmt.Sprintf("cannot read entry list %s: %v", list, err))
	} else {
		for _, line := range strings.Split(string(data), "\n") {
			line = strings.TrimSpace(line)
			if !strings.HasPrefix(line, `#include "entries/`) {
				continue
			}
			path, err := strconv.Unquote(strings.TrimPrefix(line, "#include "))
			if err != nil {
				continue
			}
			clean := filepath.Clean(filepath.FromSlash(path))
			if !strings.HasPrefix(clean, "entries"+string(filepath.Separator)) {
				issues = append(issues, "invalid entry path: "+path)
				continue
			}
			if info, err := os.Stat(filepath.Join(project, clean)); err != nil || !info.Mode().IsRegular() {
				issues = append(issues, "missing or invalid included entry: "+path)
			}
		}
	}
	templates := filepath.Join(project, "templates")
	if info, err := os.Stat(templates); err == nil {
		if !info.IsDir() {
			issues = append(issues, "templates is not a directory")
		} else {
			for _, kind := range []string{"meeting", "session", "notes"} {
				path := filepath.Join(templates, kind+".typ")
				data, err := os.ReadFile(path)
				if err != nil {
					issues = append(issues, fmt.Sprintf("cannot read %s: %v", path, err))
				} else if strings.TrimSpace(string(data)) == "" {
					issues = append(issues, "empty template: "+path)
				}
			}
		}
	} else if !errors.Is(err, os.ErrNotExist) {
		issues = append(issues, err.Error())
	}
	return issues
}

type entryInfo struct {
	Path     string
	Modified time.Time
}

func discoverEntries(project, query string) ([]entryInfo, error) {
	dir := filepath.Join(project, "entries")
	files, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}
	entries := make([]entryInfo, 0, len(files))
	for _, file := range files {
		if file.IsDir() || strings.HasPrefix(file.Name(), ".") || !strings.HasSuffix(strings.ToLower(file.Name()), ".typ") {
			continue
		}
		path := filepath.Join(dir, file.Name())
		info, err := file.Info()
		if err != nil {
			return nil, err
		}
		if !info.Mode().IsRegular() {
			continue
		}
		if query != "" {
			data, err := os.ReadFile(path)
			if err != nil {
				return nil, fmt.Errorf("cannot search %s: %w", path, err)
			}
			needle := strings.ToLower(query)
			if !strings.Contains(strings.ToLower(file.Name()), needle) && !strings.Contains(strings.ToLower(string(data)), needle) {
				continue
			}
		}
		entries = append(entries, entryInfo{Path: path, Modified: info.ModTime()})
	}
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].Modified.Equal(entries[j].Modified) {
			return entries[i].Path < entries[j].Path
		}
		return entries[i].Modified.After(entries[j].Modified)
	})
	return entries, nil
}

func journalDetails(project string) string {
	entries, err := discoverEntries(project, "")
	if err != nil {
		return "details unavailable"
	}
	if len(entries) == 0 {
		return "0 entries"
	}
	label := "entries"
	if len(entries) == 1 {
		label = "entry"
	}
	return fmt.Sprintf("%d %s · last modified %s", len(entries), label, entries[0].Modified.Local().Format("2006-01-02"))
}

func configDir() string {
	if override := os.Getenv("JOURNAL_CONFIG_DIR"); override != "" {
		return override
	}
	if runtime.GOOS == "windows" {
		if appData := os.Getenv("APPDATA"); appData != "" {
			return filepath.Join(appData, "satz-journal")
		}
	}
	if runtime.GOOS == "darwin" {
		home, _ := os.UserHomeDir()
		return filepath.Join(home, "Library", "Application Support", "satz-journal")
	}
	base := os.Getenv("XDG_CONFIG_HOME")
	if base == "" {
		home, _ := os.UserHomeDir()
		base = filepath.Join(home, ".config")
	}
	return filepath.Join(base, "satz-journal")
}

func rememberProject(path string) error {
	path, err := filepath.Abs(path)
	if err != nil {
		return err
	}
	lock, err := lockRegistry()
	if err != nil {
		return err
	}
	defer lock.Close()
	defer unlockFile(lock)
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	record := journalRecord{Name: filepath.Base(path), Path: path}
	for _, item := range registry.Journals {
		if filepath.Clean(item.Path) == filepath.Clean(path) {
			record.Name = item.Name
			break
		}
	}
	filtered := []journalRecord{record}
	for _, item := range registry.Journals {
		if filepath.Clean(item.Path) != filepath.Clean(path) {
			filtered = append(filtered, item)
		}
	}
	registry.Path = ""
	registry.Journals = filtered
	return saveRegistry(registry)
}

func setEditorPreference(value string) error {
	if value != "" {
		parts, err := splitCommand(value)
		if err != nil {
			return err
		}
		if len(parts) == 0 || strings.TrimSpace(parts[0]) == "" {
			return errors.New("editor command cannot be empty")
		}
	}
	lock, err := lockRegistry()
	if err != nil {
		return err
	}
	defer lock.Close()
	defer unlockFile(lock)
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	registry.Editor = value
	return saveRegistry(registry)
}

func preferredEditor(explicit string) (string, error) {
	if explicit != "" {
		return explicit, nil
	}
	registry, err := loadRegistry()
	if err != nil {
		return "", err
	}
	return registry.Editor, nil
}

func renameProject(path, name string) error {
	name = strings.TrimSpace(name)
	if name == "" || strings.ContainsAny(name, "\r\n\x1b") {
		return errors.New("journal name must be nonempty and fit on one line")
	}
	path, err := filepath.Abs(path)
	if err != nil {
		return err
	}
	lock, err := lockRegistry()
	if err != nil {
		return err
	}
	defer lock.Close()
	defer unlockFile(lock)
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	for i, item := range registry.Journals {
		if filepath.Clean(item.Path) == filepath.Clean(path) {
			registry.Journals[i].Name = name
			registry.Path = ""
			return saveRegistry(registry)
		}
	}
	return fmt.Errorf("journal is not registered: %s", path)
}

func lockRegistry() (*os.File, error) {
	if err := os.MkdirAll(configDir(), 0o755); err != nil {
		return nil, err
	}
	file, err := os.OpenFile(filepath.Join(configDir(), ".registry.lock"), os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return nil, fmt.Errorf("cannot lock journal list: %w", err)
	}
	if err := lockFile(file); err != nil {
		file.Close()
		return nil, fmt.Errorf("cannot lock journal list: %w", err)
	}
	return file, nil
}

func saveRegistry(registry settings) error {
	if err := os.MkdirAll(configDir(), 0o755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(registry, "", "  ")
	if err != nil {
		return err
	}
	return atomicWrite(filepath.Join(configDir(), "project.json"), data, 0o600)
}

func reconnectProject(oldPath, newPath string) error {
	oldPath, err := filepath.Abs(oldPath)
	if err != nil {
		return err
	}
	newPath, err = filepath.Abs(newPath)
	if err != nil {
		return err
	}
	if _, err := registrationPath(newPath); err != nil {
		return fmt.Errorf("cannot reconnect journal: %w", err)
	}
	lock, err := lockRegistry()
	if err != nil {
		return err
	}
	defer lock.Close()
	defer unlockFile(lock)
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	index := -1
	for i, item := range registry.Journals {
		if filepath.Clean(item.Path) == filepath.Clean(oldPath) {
			index = i
		}
		if filepath.Clean(item.Path) == filepath.Clean(newPath) && filepath.Clean(oldPath) != filepath.Clean(newPath) {
			return fmt.Errorf("journal is already registered: %s", newPath)
		}
	}
	if index < 0 {
		return fmt.Errorf("journal is not registered: %s", oldPath)
	}
	item := journalRecord{Name: registry.Journals[index].Name, Path: newPath}
	items := []journalRecord{item}
	items = append(items, registry.Journals[:index]...)
	items = append(items, registry.Journals[index+1:]...)
	registry.Path = ""
	registry.Journals = items
	return saveRegistry(registry)
}

func forgetProject(path string) error {
	path, err := filepath.Abs(path)
	if err != nil {
		return err
	}
	lock, err := lockRegistry()
	if err != nil {
		return err
	}
	defer lock.Close()
	defer unlockFile(lock)
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	items := make([]journalRecord, 0, len(registry.Journals))
	found := false
	for _, item := range registry.Journals {
		if filepath.Clean(item.Path) == filepath.Clean(path) {
			found = true
			continue
		}
		items = append(items, item)
	}
	if !found {
		return fmt.Errorf("journal is not registered: %s", path)
	}
	registry.Path = ""
	registry.Journals = items
	return saveRegistry(registry)
}

func loadRegistry() (settings, error) {
	data, err := os.ReadFile(filepath.Join(configDir(), "project.json"))
	if errors.Is(err, os.ErrNotExist) {
		return settings{}, nil
	}
	if err != nil {
		return settings{}, err
	}
	var registry settings
	if err := json.Unmarshal(data, &registry); err != nil {
		return settings{}, fmt.Errorf("cannot read journal registry: %w", err)
	}
	if registry.Path != "" && len(registry.Journals) == 0 {
		registry.Journals = []journalRecord{{Name: filepath.Base(registry.Path), Path: registry.Path}}
	}
	return registry, nil
}

func loadProject(path string) (string, error) {
	if path != "" {
		return filepath.Abs(path)
	}
	current, err := os.Getwd()
	if err == nil {
		for dir := current; ; dir = filepath.Dir(dir) {
			if isJournal(dir) {
				return dir, nil
			}
			parent := filepath.Dir(dir)
			if parent == dir {
				break
			}
		}
	}
	registry, err := loadRegistry()
	if err != nil {
		return "", err
	}
	if len(registry.Journals) > 0 && isJournal(registry.Journals[0].Path) {
		return registry.Journals[0].Path, nil
	}
	return "", errors.New("no journal selected; run `journal init PATH`, `journal use PATH`, or run from a journal folder")
}

func newEntry(path, editor string) error {
	reader := bufio.NewReader(os.Stdin)
	if path == "" && interactiveTerminal(os.Stdout) {
		for {
			registry, err := loadRegistry()
			if err != nil {
				return err
			}
			fmt.Print("\n  SATZ / JOURNAL\n  A place for your work, thoughts, and decisions.\n\n")
			available := len(registry.Journals) > 0 && isJournal(registry.Journals[0].Path)
			if available {
				fmt.Printf("  Current journal: %s\n  %s\n\n", registry.Journals[0].Name, registry.Journals[0].Path)
				fmt.Print("  Enter New entry   o Open journal   m Manage journals\n  e Editor   h Help   q Quit\n")
			} else {
				if len(registry.Journals) > 0 {
					fmt.Printf("  Recent journal unavailable: %s\n\n", registry.Journals[0].Path)
				}
				fmt.Print("  c Create journal   a Connect journal   m Manage journals\n  e Editor   h Help   q Quit\n")
			}
			state, err := term.MakeRaw(int(os.Stdin.Fd()))
			if err != nil {
				return err
			}
			choice, readErr := readHomeChoice(reader)
			restoreErr := term.Restore(int(os.Stdin.Fd()), state)
			if readErr != nil {
				return readErr
			}
			if restoreErr != nil {
				return restoreErr
			}
			switch choice {
			case "quit":
				return errCancelled
			case "help":
				printHelp()
			case "editor":
				current, err := preferredEditor("")
				if err != nil {
					fmt.Println("  ", err)
					continue
				}
				if current == "" {
					fmt.Println("  Editor: automatic (VISUAL, EDITOR, or VS Code)")
				} else {
					fmt.Println("  Editor:", current)
				}
				fmt.Print("  Editor command (e.g. code, nvim; Enter keeps current, /cancel cancels): ")
				command, err := reader.ReadString('\n')
				command = strings.TrimSpace(command)
				if err != nil && command == "" {
					return errCancelled
				}
				if command == "" || command == "/cancel" {
					continue
				}
				if err := setEditorPreference(command); err != nil {
					fmt.Println("  ", err)
				} else {
					fmt.Println("  Editor saved:", command)
				}
			case "open":
				if !available {
					fmt.Println("  Select or create a journal first.")
					continue
				}
				if err := run([]string{"open", registry.Journals[0].Path}); err != nil {
					fmt.Println("  ", err)
				}
			case "create", "connect", "manage":
				initial := ""
				if choice == "create" {
					initial = "c"
				}
				if choice == "connect" {
					initial = "a"
				}
				project, err := chooseJournalWithChoice(reader, os.Stdout, true, false, initial)
				if err != nil {
					if !errors.Is(err, errCancelled) {
						fmt.Println("  ", err)
					}
					continue
				}
				fmt.Println("  Current journal:", project)
			case "new":
				if !available {
					fmt.Println("  Create or connect a journal first.")
					continue
				}
				path = registry.Journals[0].Path
				goto entry
			}
		}
	}
entry:
	var project string
	var err error
	if path != "" {
		project, err = loadProject(path)
	} else {
		project, err = chooseJournal(reader, os.Stdout)
	}
	if err != nil {
		return err
	}
	fmt.Println("Selected journal:", project)
	fmt.Println("Type /cancel at an entry prompt to stop.")
	title, err := ask(reader, "Entry title: ")
	if err != nil {
		return err
	}
	title = strings.TrimSpace(title)
	if title == "" {
		return errors.New("title cannot be empty")
	}
	var kind string
	for {
		kind, err = ask(reader, "Entry type (meeting/session/notes; m/s/n) [notes]: ")
		if err != nil {
			return err
		}
		kind = normalizeKind(kind)
		if kind == "" {
			kind = "notes"
		}
		if validKind(kind) {
			break
		}
		fmt.Println("Choose meeting, session, or notes (m/s/n).")
	}
	keywords, err := ask(reader, "Keywords (comma-separated, optional): ")
	if err != nil {
		return err
	}
	entry, err := createEntry(project, title, kind, strings.TrimSpace(keywords), time.Now())
	if err != nil {
		return err
	}
	fmt.Println("Created", entry)
	if err := rememberProject(project); err != nil {
		fmt.Fprintln(os.Stderr, "Entry saved, but could not update recent journal:", err)
	}
	editor, err = preferredEditor(editor)
	if err != nil {
		return fmt.Errorf("entry saved at %s, but editor preference could not be read: %w", entry, err)
	}
	opened, err := openEditor(project, entry, editor)
	if err != nil {
		return fmt.Errorf("entry saved at %s, but editor could not be opened: %w", entry, err)
	}
	if !opened {
		fmt.Println("Your entry is saved. Set an editor with journal editor 'COMMAND', then open the file shown above.")
	}
	return nil
}

func readHomeChoice(reader *bufio.Reader) (string, error) {
	for {
		key, err := reader.ReadByte()
		if err != nil {
			return "", err
		}
		switch key {
		case '\r', '\n', 'n', 'N':
			return "new", nil
		case 'm', 'M':
			return "manage", nil
		case 'c', 'C':
			return "create", nil
		case 'a', 'A':
			return "connect", nil
		case 'o', 'O':
			return "open", nil
		case 'e', 'E':
			return "editor", nil
		case 'h', 'H', '?':
			return "help", nil
		case 'q', 'Q', 3:
			return "quit", nil
		}
	}
}

// chooseJournal uses numbered choices so it works in ordinary terminals and pipes.
func chooseJournal(reader *bufio.Reader, out io.Writer) (string, error) {
	return chooseJournalMode(reader, out, false)
}

func chooseJournalMode(reader *bufio.Reader, out io.Writer, manage bool) (string, error) {
	return chooseJournalDetails(reader, out, manage, false)
}

func chooseJournalDetails(reader *bufio.Reader, out io.Writer, manage, details bool) (string, error) {
	return chooseJournalWithChoice(reader, out, manage, details, "")
}

func chooseJournalWithChoice(reader *bufio.Reader, out io.Writer, manage, details bool, initial string) (string, error) {
	registry, err := loadRegistry()
	if err != nil {
		return "", err
	}
	if details {
		for i := range registry.Journals {
			registry.Journals[i].Details = journalDetails(registry.Journals[i].Path)
		}
	}
	color := terminalColor(out)
	fmt.Fprintf(out, "\n  %s\n  Your journals\n\n", styled("SATZ JOURNAL", "1;36", color))
	if !manage && len(registry.Journals) == 1 && isJournal(registry.Journals[0].Path) {
		item := registry.Journals[0]
		return item.Path, nil
	}
	if len(registry.Journals) == 0 {
		fmt.Fprint(out, "  No journals connected yet.\n\n")
	} else if !interactiveTerminal(out) {
		for i, item := range registry.Journals {
			suffix := ""
			if i == 0 {
				suffix = "  (recent)"
			}
			if !isJournal(item.Path) {
				suffix += "  (unavailable)"
			}
			if item.Details != "" {
				suffix += "  · " + item.Details
			}
			name := item.Name
			if i == 0 {
				name = "› " + name
			} else {
				name = "  " + name
			}
			fmt.Fprintf(out, "  %d  %s%s\n       %s\n", i+1, name, suffix, item.Path)
		}
	}
	if !interactiveTerminal(out) || len(registry.Journals) == 0 {
		fmt.Fprintln(out, "\n  c  Create a journal\n  a  Connect an existing journal\n  r  Reconnect a moved journal\n  f  Remove from list (keep files)\n  q  Cancel")
	}
	for {
		line, readErr := initial, error(nil)
		if initial == "" {
			line, readErr = journalChoice(reader, out, registry.Journals)
		}
		initial = ""
		choice := strings.TrimSpace(line)
		selectedIndex := 0
		if len(choice) > 2 && choice[1] == ':' {
			selectedIndex, _ = strconv.Atoi(choice[2:])
			choice = choice[:1]
			if selectedIndex < 1 || selectedIndex > len(registry.Journals) {
				fmt.Fprintln(out, "  Choose a listed journal.")
				continue
			}
		}
		if readErr != nil && choice == "" {
			return "", errCancelled
		}
		switch strings.ToLower(choice) {
		case "q":
			return "", errCancelled
		case "f":
			if len(registry.Journals) == 0 {
				fmt.Fprintln(out, "  No registered journal to remove.")
				continue
			}
			index := selectedIndex
			if index == 0 {
				index = 1
			}
			if selectedIndex == 0 && len(registry.Journals) > 1 {
				fmt.Fprint(out, "  Journal number (q to cancel): ")
				answer, err := reader.ReadString('\n')
				if cancelledInput(answer) {
					return "", errCancelled
				}
				if err != nil && strings.TrimSpace(answer) == "" {
					return "", errCancelled
				}
				index, err = strconv.Atoi(strings.TrimSpace(answer))
				if err != nil || index < 1 || index > len(registry.Journals) {
					fmt.Fprintln(out, "  Choose a listed journal number.")
					continue
				}
			}
			item := registry.Journals[index-1]
			fmt.Fprintf(out, "  Remove %s (%s) from the list? Files will remain. [y/N]: ", item.Name, item.Path)
			answer, _ := reader.ReadString('\n')
			if !strings.EqualFold(strings.TrimSpace(answer), "y") {
				fmt.Fprintln(out, "  Removal cancelled.")
				continue
			}
			if err := forgetProject(item.Path); err != nil {
				return "", err
			}
			fmt.Fprintf(out, "  Removed %s from the list; its files remain at %s.\n", item.Name, item.Path)
			return chooseJournalDetails(reader, out, true, details)
		case "r":
			if len(registry.Journals) == 0 {
				fmt.Fprintln(out, "  No registered journal to reconnect.")
				continue
			}
			index := selectedIndex
			if index == 0 {
				index = 1
			}
			if selectedIndex == 0 && len(registry.Journals) > 1 {
				fmt.Fprint(out, "  Journal number (q to cancel): ")
				answer, err := reader.ReadString('\n')
				if cancelledInput(answer) {
					return "", errCancelled
				}
				if err != nil && strings.TrimSpace(answer) == "" {
					return "", errCancelled
				}
				index, err = strconv.Atoi(strings.TrimSpace(answer))
				if err != nil || index < 1 || index > len(registry.Journals) {
					fmt.Fprintln(out, "  Choose a listed journal number.")
					continue
				}
			}
			fmt.Fprint(out, "  New journal folder (q to cancel): ")
			answer, err := reader.ReadString('\n')
			if cancelledInput(answer) {
				return "", errCancelled
			}
			if strings.TrimSpace(answer) == "" {
				if err != nil {
					return "", errCancelled
				}
				fmt.Fprintln(out, "  Enter a folder path.")
				continue
			}
			path, err := normalizeInputPath(strings.TrimSpace(answer))
			if err != nil {
				return "", err
			}
			if err := reconnectProject(registry.Journals[index-1].Path, path); err != nil {
				return "", err
			}
			return path, nil
		case "c", "a":
			if strings.EqualFold(choice, "c") {
				fmt.Fprint(out, "  New journal folder (e.g. ~/Documents/My-Journal; q to cancel): ")
			} else {
				fmt.Fprint(out, "  Existing journal folder (q to cancel): ")
			}
			input, inputErr := reader.ReadString('\n')
			if cancelledInput(input) {
				return "", errCancelled
			}
			input = strings.TrimSpace(input)
			if input == "" {
				if inputErr != nil {
					return "", errCancelled
				}
				fmt.Fprintln(out, "  Enter a folder path.")
				continue
			}
			path, err := normalizeInputPath(input)
			if err != nil {
				return "", err
			}
			if strings.EqualFold(choice, "c") {
				path, err = initProject(path)
				if err != nil {
					return "", err
				}
			} else if _, err := registrationPath(path); err != nil {
				return "", fmt.Errorf("cannot connect journal: %w", err)
			}
			if err := rememberProject(path); err != nil {
				return "", err
			}
			if strings.EqualFold(choice, "c") {
				fmt.Fprintf(out, "  Journal created with starter files: %s\n  Edit config.typ for your name and title; open main.typ to preview.\n", path)
			} else {
				fmt.Fprintf(out, "  Journal connected: %s\n", path)
			}
			return path, nil
		default:
			if choice == "" && len(registry.Journals) > 0 {
				choice = "1"
			}
			index, err := strconv.Atoi(choice)
			if err != nil || index < 1 || index > len(registry.Journals) {
				fmt.Fprintln(out, "  Choose a listed number, c, a, r, f, or q.")
				if readErr != nil {
					return "", errCancelled
				}
				continue
			}
			item := registry.Journals[index-1]
			if !isJournal(item.Path) {
				return "", fmt.Errorf("journal is unavailable: %s; choose r to reconnect it or run `journal reconnect OLD_PATH NEW_PATH`", item.Path)
			}
			if manage {
				if err := rememberProject(item.Path); err != nil {
					return "", err
				}
			}
			return item.Path, nil
		}
	}
}

// journalChoice keeps line-based input for pipes and terminals that cannot use
// raw mode; an interactive terminal gets a keyboard-controlled selection.
func journalChoice(reader *bufio.Reader, out io.Writer, items []journalRecord) (string, error) {
	if len(items) > 0 && interactiveTerminal(out) {
		state, err := term.MakeRaw(int(os.Stdin.Fd()))
		if err == nil {
			choice, readErr := interactiveChoice(reader, out, items, terminalColor(out))
			restoreErr := term.Restore(int(os.Stdin.Fd()), state)
			fmt.Fprintln(out)
			if readErr != nil {
				return "", readErr
			}
			return choice, restoreErr
		}
		for i, item := range items {
			fmt.Fprintf(out, "  %d  %s\n     %s\n", i+1, item.Name, item.Path)
		}
		fmt.Fprintln(out, "  c Create   a Connect   r Reconnect   f Remove   q Cancel")
	}
	fmt.Fprint(out, "\n  Choose: ")
	return reader.ReadString('\n')
}

func interactiveTerminal(out io.Writer) bool {
	file, ok := out.(*os.File)
	return ok && os.Getenv("TERM") != "dumb" && term.IsTerminal(int(os.Stdin.Fd())) && term.IsTerminal(int(file.Fd()))
}

func fitLine(s string, width int) string {
	runes := []rune(s)
	if len(runes) <= width {
		return s
	}
	if width < 2 {
		return ""
	}
	return string(runes[:width-1]) + "…"
}

func journalViewport(selected, count, height int) (int, int) {
	visible := (height - 6) / 2
	if visible < 1 {
		visible = 1
	}
	if visible > count {
		visible = count
	}
	start := 0
	if selected >= visible {
		start = selected - visible + 1
	}
	return start, start + visible
}

func interactiveChoice(reader *bufio.Reader, out io.Writer, items []journalRecord, color bool) (string, error) {
	selected := 0
	width, height := 72, 24
	if file, ok := out.(*os.File); ok {
		if w, h, err := term.GetSize(int(file.Fd())); err == nil && w > 8 {
			width = w - 1
			if h > 0 {
				height = h
			}
		}
	}
	first := true
	previousLines := 0
	for {
		if !first {
			fmt.Fprintf(out, "\x1b[%dA", previousLines)
		}
		first = false
		start, end := journalViewport(selected, len(items), height)
		previousLines = (end-start)*2 + 3
		for i := start; i < end; i++ {
			item := items[i]
			prefix := "    "
			if i == selected {
				prefix = "  › "
			}
			label := prefix + item.Name
			if i == 0 {
				label += "  (recent)"
			}
			if !isJournal(item.Path) {
				label += "  (unavailable)"
			}
			if item.Details != "" {
				label += "  · " + item.Details
			}
			label = fitLine(label, width)
			if i == selected {
				label = styled(label, "1;36", color)
			}
			fmt.Fprintf(out, "\r\x1b[2K%s\r\n\r\x1b[2K%s\r\n", label, fitLine("      "+item.Path, width))
		}
		position := ""
		if len(items) > end-start {
			position = fmt.Sprintf("  Journal %d of %d", selected+1, len(items))
		}
		fmt.Fprintf(out, "\r\x1b[2K%s\r\n\r\x1b[2K%s\r\n\r\x1b[2K%s\r\n", fitLine(position, width), fitLine("  ↑↓ Navigate   Enter Select   q Quit", width), fitLine("  c Create   a Connect   r Reconnect   f Remove", width))
		key, err := reader.ReadByte()
		if err != nil {
			return "", err
		}
		switch key {
		case '\r', '\n':
			return strconv.Itoa(selected + 1), nil
		case 3, 'q', 'Q':
			return "q", nil
		case 'r', 'R', 'f', 'F':
			return fmt.Sprintf("%s:%d", strings.ToLower(string(key)), selected+1), nil
		case 'c', 'C', 'a', 'A':
			return strings.ToLower(string(key)), nil
		case '\x1b':
			prefix, err := reader.ReadByte()
			if err != nil {
				return "", err
			}
			if prefix != '[' && prefix != 'O' {
				if err := reader.UnreadByte(); err != nil {
					return "", err
				}
				continue
			}
			direction, err := reader.ReadByte()
			if err != nil {
				return "", err
			}
			if direction == 'A' {
				selected = (selected + len(items) - 1) % len(items)
			}
			if direction == 'B' {
				selected = (selected + 1) % len(items)
			}
		default:
			if key >= '1' && key <= '9' && int(key-'1') < len(items) {
				selected = int(key - '1')
			}
		}
	}
}

func terminalColor(out io.Writer) bool {
	if _, disabled := os.LookupEnv("NO_COLOR"); disabled || os.Getenv("TERM") == "dumb" {
		return false
	}
	file, ok := out.(*os.File)
	if !ok {
		return false
	}
	info, err := file.Stat()
	return err == nil && info.Mode()&os.ModeCharDevice != 0
}

func styled(text, code string, enabled bool) string {
	if !enabled {
		return text
	}
	return "\x1b[" + code + "m" + text + "\x1b[0m"
}

func writeShortcut(output, executable, platform string) error {
	var content string
	switch platform {
	case "darwin":
		content = "#!/bin/sh\nexec '" + strings.ReplaceAll(executable, "'", "'\\''") + "'\n"
	case "linux":
		if strings.ContainsAny(executable, "\r\n") {
			return errors.New("cannot create a desktop launcher for a path containing a newline")
		}
		quoted := strings.NewReplacer("\\", "\\\\", "\"", "\\\"", "`", "\\`", "$", "\\$", "%", "%%").Replace(executable)
		content = "[Desktop Entry]\nType=Application\nName=Satz Journal\nComment=Start a journal entry\nTerminal=true\nExec=\"" + quoted + "\"\n"
	case "windows":
		content = "@echo off\r\nsetlocal DisableDelayedExpansion\r\n\"" + strings.ReplaceAll(executable, "%", "%%") + "\"\r\n"
	default:
		return fmt.Errorf("desktop shortcuts are not supported on %s", platform)
	}
	file, err := os.OpenFile(output, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0o755)
	if err != nil {
		return fmt.Errorf("cannot create shortcut %s: %w", output, err)
	}
	if _, err := io.WriteString(file, content); err != nil {
		file.Close()
		return cleanupFailedEntry(output, err)
	}
	if err := file.Close(); err != nil {
		return cleanupFailedEntry(output, err)
	}
	return nil
}

func ask(reader *bufio.Reader, prompt string) (string, error) {
	fmt.Print(prompt)
	value, err := reader.ReadString('\n')
	if errors.Is(err, io.EOF) && value == "" {
		return "", errCancelled
	}
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	value = strings.TrimRight(value, "\r\n")
	if strings.TrimSpace(value) == "/cancel" {
		return "", errCancelled
	}
	return value, nil
}

func cancelledInput(value string) bool {
	value = strings.TrimSpace(value)
	return value == "/cancel" || strings.EqualFold(value, "q")
}

func validKind(kind string) bool { return kind == "meeting" || kind == "session" || kind == "notes" }

func normalizeKind(kind string) string {
	kind = strings.ToLower(strings.TrimSpace(kind))
	switch kind {
	case "m":
		return "meeting"
	case "s":
		return "session"
	case "n":
		return "notes"
	default:
		return kind
	}
}

func typstString(value string) string {
	value = strings.ReplaceAll(value, "\\", "\\\\")
	value = strings.ReplaceAll(value, `"`, `\"`)
	value = strings.ReplaceAll(value, "\r", "")
	value = strings.ReplaceAll(value, "\n", `\n`)
	return `"` + value + `"`
}

func safeComponent(value string) string {
	var out strings.Builder
	separator := false
	for _, r := range strings.ToLower(strings.TrimSpace(value)) {
		if unicode.IsLetter(r) || unicode.IsDigit(r) || r == '_' {
			if separator && out.Len() > 0 {
				out.WriteByte('-')
			}
			out.WriteRune(r)
			separator = false
		} else {
			separator = true
		}
		if out.Len() >= 60 {
			break
		}
	}
	result := strings.Trim(out.String(), "-_")
	if result == "" {
		return "entry"
	}
	return result
}

func registrationPath(project string) (string, error) {
	main := filepath.Join(project, "main.typ")
	mainBytes, err := os.ReadFile(main)
	if err != nil {
		return "", fmt.Errorf("not a journal project: %w", err)
	}
	if info, err := os.Stat(filepath.Join(project, "entries")); err != nil || !info.IsDir() {
		return "", fmt.Errorf("not a journal project: entries/ must be a directory")
	}
	if info, err := os.Stat(filepath.Join(project, "setup.typ")); err != nil || info.IsDir() {
		return "", fmt.Errorf("journal setup.typ is missing: %s", project)
	}
	registration := main
	entryList := filepath.Join(project, "journal-entries.typ")
	linked := hasLine(string(mainBytes), `#include "journal-entries.typ"`)
	if _, err := os.Stat(entryList); err == nil {
		if !linked {
			return "", fmt.Errorf("%s does not include journal-entries.typ; restore the line #include \"journal-entries.typ\" where entries should appear", main)
		}
		registration = entryList
	} else if errors.Is(err, os.ErrNotExist) && linked {
		return "", fmt.Errorf("%s is missing; restore it from a backup or recreate it with your entry includes and %q", entryList, entriesMarker)
	} else if !errors.Is(err, os.ErrNotExist) {
		return "", err
	}
	registrationBytes, err := os.ReadFile(registration)
	if err != nil {
		return "", err
	}
	info, err := os.Lstat(registration)
	if err != nil {
		return "", err
	}
	if info.Mode()&os.ModeSymlink != 0 {
		return "", fmt.Errorf("entry list %s is a symbolic link; replace the link with a regular file before creating entries", registration)
	}
	if countLines(string(registrationBytes), entriesMarker) != 1 {
		return "", fmt.Errorf("%s must contain exactly one %q line; restore it after the entry includes", registration, entriesMarker)
	}
	return registration, nil
}

func countLines(content, line string) int {
	count := 0
	for _, candidate := range strings.Split(content, "\n") {
		if strings.TrimSpace(candidate) == line {
			count++
		}
	}
	return count
}

func hasLine(content, line string) bool { return countLines(content, line) > 0 }

func createEntry(project, title, kind, keywords string, date time.Time) (string, error) {
	title = strings.TrimSpace(title)
	kind = strings.ToLower(strings.TrimSpace(kind))
	if title == "" {
		return "", errors.New("title cannot be empty")
	}
	if !validKind(kind) {
		return "", errors.New("entry type must be meeting, session, or notes")
	}
	project, err := filepath.Abs(project)
	if err != nil {
		return "", err
	}
	if !isJournal(project) {
		return "", fmt.Errorf("not a journal project (expected main.typ and entries/): %s", project)
	}
	lock, err := os.OpenFile(filepath.Join(project, ".satz-journal.lock"), os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return "", fmt.Errorf("cannot lock journal: %w", err)
	}
	defer lock.Close()
	if err := lockFile(lock); err != nil {
		return "", fmt.Errorf("cannot lock journal: %w", err)
	}
	defer unlockFile(lock)
	// Read the entry list only after acquiring the lock. On Windows an open
	// reader can otherwise prevent the concurrent atomic replacement.
	registration, err := registrationPath(project)
	if err != nil {
		return "", err
	}
	basename := date.Format("2006-01-02") + "-" + safeComponent(title)
	sections := scaffold(kind) // Existing projects without templates retain their old behavior.
	templatesDir := filepath.Join(project, "templates")
	if _, err := os.Stat(templatesDir); err == nil {
		path := filepath.Join(templatesDir, kind+".typ")
		data, err := os.ReadFile(path)
		if err != nil {
			return "", fmt.Errorf("cannot read entry template %s: %w", path, err)
		}
		if strings.TrimSpace(string(data)) == "" {
			return "", fmt.Errorf("entry template is empty: %s", path)
		}
		sections = string(data)
		if !strings.HasSuffix(sections, "\n") {
			sections += "\n"
		}
	} else if !errors.Is(err, os.ErrNotExist) {
		return "", err
	}
	content := "#import \"../setup.typ\": journal-entry\n\n" +
		"#journal-entry(\n" +
		"  title: " + typstString(title) + ",\n" +
		"  date: " + typstString(date.Format("Monday, 02/01/2006")) + ",\n" +
		"  keywords: " + typstString(keywords) + ",\n" +
		")[\n" + sections + "]\n"
	if sections != scaffold(kind) {
		if err := validateTemplate(project, kind, content); err != nil {
			return "", err
		}
	}
	var file *os.File
	var target, relative string
	for n := 1; n <= 10000; n++ {
		filename := basename
		if n > 1 {
			filename += "-" + strconv.Itoa(n)
		}
		filename += ".typ"
		target = filepath.Join(project, "entries", filename)
		relative = filepath.ToSlash(filepath.Join("entries", filename))
		file, err = os.OpenFile(target, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
		if errors.Is(err, os.ErrExist) {
			continue
		}
		if err != nil {
			return "", err
		}
		break
	}
	if file == nil {
		return "", errors.New("could not find an available entry filename; choose a different title")
	}
	if _, err := io.WriteString(file, content); err != nil {
		file.Close()
		return "", cleanupFailedEntry(target, err)
	}
	if err := file.Close(); err != nil {
		return "", cleanupFailedEntry(target, err)
	}
	if err := appendInclude(registration, relative); err != nil {
		return "", cleanupFailedEntry(target, err)
	}
	return target, nil
}

func cleanupFailedEntry(path string, cause error) error {
	if err := os.Remove(path); err != nil && !errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("entry creation failed: %w; could not remove the incomplete file %s: %v; check it before removing it manually", cause, path, err)
	}
	return cause
}

// Validate customized content in the same directory and project context as a
// real entry, without changing the entry list or creating the final file.
func validateTemplate(project, kind, content string) error {
	typst, err := exec.LookPath("typst")
	if err != nil {
		return fmt.Errorf("the %s template was customized; install the Typst CLI to validate it before creating an entry (https://typst.app/open-source/#download)", kind)
	}
	source, err := os.CreateTemp(filepath.Join(project, "entries"), ".satz-template-check-*.typ")
	if err != nil {
		return fmt.Errorf("cannot validate %s template: %w", kind, err)
	}
	sourcePath := source.Name()
	defer os.Remove(sourcePath)
	if _, err := io.WriteString(source, content); err != nil {
		source.Close()
		return fmt.Errorf("cannot validate %s template: %w", kind, err)
	}
	if err := source.Close(); err != nil {
		return fmt.Errorf("cannot validate %s template: %w", kind, err)
	}
	output, err := os.CreateTemp("", "satz-template-check-*.pdf")
	if err != nil {
		return fmt.Errorf("cannot validate %s template: %w", kind, err)
	}
	outputPath := output.Name()
	if err := output.Close(); err != nil {
		os.Remove(outputPath)
		return err
	}
	defer os.Remove(outputPath)
	result, err := compileTemplateCheck(typst, project, sourcePath, outputPath)
	if err != nil && strings.Contains(string(result), "does not exist in the document") {
		// A reference can resolve only in the full journal. Retry in that
		// context without editing the user's main file or entry list.
		wrapper, createErr := os.CreateTemp(project, ".satz-journal-check-*.typ")
		if createErr != nil {
			return fmt.Errorf("cannot validate %s template in journal context: %w", kind, createErr)
		}
		wrapperPath := wrapper.Name()
		defer os.Remove(wrapperPath)
		content := "#include \"main.typ\"\n#include \"entries/" + filepath.Base(sourcePath) + "\"\n"
		if _, createErr = io.WriteString(wrapper, content); createErr != nil {
			wrapper.Close()
			return createErr
		}
		if createErr = wrapper.Close(); createErr != nil {
			return createErr
		}
		result, err = compileTemplateCheck(typst, project, wrapperPath, outputPath)
	}
	if err != nil {
		return fmt.Errorf("cannot compile %s template or journal; fix the reported issue and try again: %w\n%s", kind, err, strings.TrimSpace(string(result)))
	}
	return nil
}

func compileTemplateCheck(typst, project, source, output string) ([]byte, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	result, err := exec.CommandContext(ctx, typst, "compile", "--root", project, source, output).CombinedOutput()
	if ctx.Err() != nil {
		return result, errors.New("validation timed out after 30 seconds; no entry was created")
	}
	return result, err
}

func scaffold(kind string) string {
	switch kind {
	case "meeting":
		return "  == Agenda\n  - Add agenda items here.\n\n" +
			"  == What we talked about\n\n  == Outcomes\n\n  == Rationale\n\n" +
			"  == Action Items\n  - [ ] Add an action item\n\n  == Questions\n"
	case "session":
		return "  == Goal\n  Describe the goal for this session.\n\n" +
			"  == Log\n\n  == Outcomes\n\n  == Rationale\n\n" +
			"  == Next Steps\n  - [ ] Add the next step\n\n  == Questions\n"
	default:
		return "  == Notes\n  Add your notes here.\n"
	}
}

func writeDefaultTemplate(project, kind string) (string, error) {
	if !validKind(kind) {
		return "", errors.New("template kind must be meeting, session, or notes")
	}
	dir := filepath.Join(project, "templates")
	info, err := os.Stat(dir)
	if err != nil || !info.IsDir() {
		return "", fmt.Errorf("template folder is missing: %s; create all three templates before using it", dir)
	}
	path := filepath.Join(dir, kind+".default.typ")
	file, err := os.OpenFile(path, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0o644)
	if err != nil {
		return "", fmt.Errorf("cannot create default template copy %s: %w", path, err)
	}
	if _, err := io.WriteString(file, scaffold(kind)); err != nil {
		file.Close()
		return "", cleanupFailedEntry(path, err)
	}
	if err := file.Close(); err != nil {
		return "", cleanupFailedEntry(path, err)
	}
	return path, nil
}

func appendInclude(main, relative string) error {
	info, err := os.Lstat(main)
	if err != nil {
		return err
	}
	if info.Mode()&os.ModeSymlink != 0 {
		return fmt.Errorf("entry list %s is a symbolic link; no changes made", main)
	}
	data, err := os.ReadFile(main)
	if err != nil {
		return err
	}
	text := string(data)
	line := "#include \"" + relative + "\""
	if countLines(text, entriesMarker) != 1 {
		return fmt.Errorf("%s must contain exactly one %q line", main, entriesMarker)
	}
	if hasLine(text, line) {
		return nil
	}
	lines := strings.Split(text, "\n")
	for i, existing := range lines {
		if strings.TrimSpace(existing) == entriesMarker {
			ending := "\n"
			if strings.HasSuffix(existing, "\r") {
				ending = "\r\n"
			}
			lines[i] = line + ending + existing
			break
		}
	}
	text = strings.Join(lines, "\n")
	return atomicWrite(main, []byte(text), info.Mode().Perm())
}

func atomicWrite(path string, data []byte, mode os.FileMode) error {
	file, err := os.CreateTemp(filepath.Dir(path), ".journal-*.tmp")
	if err != nil {
		return err
	}
	temp := file.Name()
	defer os.Remove(temp)
	if err := file.Chmod(mode); err != nil {
		file.Close()
		return err
	}
	if _, err := file.Write(data); err != nil {
		file.Close()
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return os.Rename(temp, path)
}

// splitCommand parses a quoted executable and flags without invoking a shell.
func splitCommand(command string) ([]string, error) {
	var args []string
	var current strings.Builder
	var quote rune
	active := false
	runes := []rune(command)
	for i := 0; i < len(runes); i++ {
		r := runes[i]
		if quote != 0 {
			if r == quote {
				quote = 0
			} else if r == '\\' && quote == '"' && i+1 < len(runes) && runes[i+1] == '"' {
				current.WriteRune('"')
				i++
			} else {
				current.WriteRune(r)
			}
			active = true
			continue
		}
		if r == '"' || r == '\'' {
			quote = r
			active = true
			continue
		}
		if unicode.IsSpace(r) {
			if active {
				args = append(args, current.String())
				current.Reset()
				active = false
			}
			continue
		}
		current.WriteRune(r)
		active = true
	}
	if quote != 0 {
		return nil, errors.New("unterminated quote in editor command")
	}
	if active {
		args = append(args, current.String())
	}
	return args, nil
}

func editorCommand(project, entry, requested string, goos string, lookPath func(string) (string, error), stat func(string) (os.FileInfo, error)) ([]string, bool, error) {
	value := requested
	if value == "" {
		value = os.Getenv("VISUAL")
	}
	if value == "" {
		value = os.Getenv("EDITOR")
	}
	if value == "" {
		value = "code"
	}
	parts, err := splitCommand(value)
	if err != nil {
		return nil, false, nil
	}
	if len(parts) == 0 {
		return nil, false, nil
	}
	resolved, err := lookPath(parts[0])
	if err != nil {
		return nil, false, nil
	}
	name := strings.ToLower(filepath.Base(parts[0]))
	if goos == "windows" {
		name = strings.ToLower(filepath.Base(strings.ReplaceAll(parts[0], `\`, "/")))
		resolved = windowsCodeExecutable(resolved, name, stat)
		if resolved == "" {
			return nil, false, nil
		}
	}
	args := append([]string{resolved}, parts[1:]...)
	if strings.TrimSuffix(name, ".cmd") == "code" || name == "code.exe" {
		args = append(args, "--reuse-window", project)
		if entry != "" {
			args = append(args, entry)
		}
	} else {
		if entry == "" {
			args = append(args, project)
		} else {
			args = append(args, entry)
		}
	}
	return args, true, nil
}

func windowsCodeExecutable(found, originalName string, stat func(string) (os.FileInfo, error)) string {
	if strings.EqualFold(filepath.Ext(found), ".cmd") || strings.EqualFold(filepath.Ext(found), ".bat") || originalName == "code.cmd" || originalName == "code.bat" {
		binDir := filepath.Dir(strings.ReplaceAll(found, `\`, "/"))
		candidate := filepath.Join(filepath.Dir(binDir), "Code.exe")
		if info, err := stat(candidate); err == nil && !info.IsDir() {
			return candidate
		}
		return ""
	}
	return found
}

func openEditor(project, entry, requested string) (bool, error) {
	args, ok, err := editorCommand(project, entry, requested, runtime.GOOS, exec.LookPath, os.Stat)
	if err != nil || !ok {
		return ok, err
	}
	cmd := exec.Command(args[0], args[1:]...)
	cmd.Dir = project
	cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
	return true, cmd.Run()
}

func writeStarterZip(output string) error {
	output, err := filepath.Abs(output)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(output), 0o755); err != nil {
		return err
	}
	temp, err := os.MkdirTemp("", "satz-journal-starter-*")
	if err != nil {
		return err
	}
	defer os.RemoveAll(temp)
	project, err := initProject(filepath.Join(temp, "satz-journal-starter"))
	if err != nil {
		return err
	}
	zipFile, err := os.OpenFile(output, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		if errors.Is(err, os.ErrExist) {
			return fmt.Errorf("starter ZIP destination already exists: %s", output)
		}
		return err
	}
	complete := false
	defer func() {
		if !complete {
			_ = os.Remove(output)
		}
	}()
	writer := zip.NewWriter(zipFile)
	files := make([]string, 0)
	err = filepath.WalkDir(project, func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !entry.IsDir() {
			files = append(files, path)
		}
		return nil
	})
	if err == nil {
		sort.Strings(files)
		var archiveErr error
		for _, path := range files {
			relative, relErr := filepath.Rel(temp, path)
			if relErr != nil {
				archiveErr = relErr
				break
			}
			entry, createErr := writer.Create(filepath.ToSlash(relative))
			if createErr != nil {
				archiveErr = createErr
				break
			}
			data, readErr := os.ReadFile(path)
			if readErr != nil {
				archiveErr = readErr
				break
			}
			if _, writeErr := entry.Write(data); writeErr != nil {
				archiveErr = writeErr
				break
			}
		}
		if archiveErr != nil {
			err = archiveErr
		}
	}
	closeErr := writer.Close()
	fileErr := zipFile.Close()
	if err != nil {
		return err
	}
	if closeErr != nil {
		return closeErr
	}
	if fileErr != nil {
		return fileErr
	}
	complete = true
	fmt.Println("Starter ZIP written to", output)
	return nil
}
