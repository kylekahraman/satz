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
)

//go:embed runtime templates
var assets embed.FS

const entriesMarker = "// --- end entries ---"

type settings struct {
	Path     string          `json:"path,omitempty"` // Legacy single-journal setting.
	Journals []journalRecord `json:"journals,omitempty"`
}

type journalRecord struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

func main() {
	if err := run(os.Args[1:]); err != nil {
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
  journal reconnect OLD NEW     Update a moved journal's registered path
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

func initProject(input string) (string, error) {
	destination, err := filepath.Abs(input)
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
	if err := os.WriteFile(filepath.Join(destination, ".gitignore"), []byte("*.pdf\n"), 0o644); err != nil {
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
	registry, err := loadRegistry()
	if err != nil {
		return err
	}
	record := journalRecord{Name: filepath.Base(path), Path: path}
	filtered := []journalRecord{record}
	for _, item := range registry.Journals {
		if filepath.Clean(item.Path) != filepath.Clean(path) {
			filtered = append(filtered, item)
		}
	}
	return saveRegistry(settings{Journals: filtered})
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
	item := journalRecord{Name: filepath.Base(newPath), Path: newPath}
	items := []journalRecord{item}
	items = append(items, registry.Journals[:index]...)
	items = append(items, registry.Journals[index+1:]...)
	return saveRegistry(settings{Journals: items})
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
	opened, err := openEditor(project, entry, editor)
	if err != nil {
		return fmt.Errorf("entry saved at %s, but editor could not be opened: %w", entry, err)
	}
	if !opened {
		fmt.Println("Your entry is saved. Open the journal folder in your editor and select this file.")
	}
	return nil
}

// chooseJournal uses numbered choices so it works in ordinary terminals and pipes.
func chooseJournal(reader *bufio.Reader, out io.Writer) (string, error) {
	registry, err := loadRegistry()
	if err != nil {
		return "", err
	}
	color := terminalColor(out)
	fmt.Fprintf(out, "\n  %s\n  Your journals\n\n", styled("SATZ JOURNAL", "1;36", color))
	if len(registry.Journals) == 1 && isJournal(registry.Journals[0].Path) {
		item := registry.Journals[0]
		return item.Path, nil
	}
	if len(registry.Journals) == 0 {
		fmt.Fprint(out, "  No journals connected yet.\n\n")
	} else {
		for i, item := range registry.Journals {
			suffix := ""
			if i == 0 {
				suffix = "  (recent)"
			}
			if !isJournal(item.Path) {
				suffix += "  (unavailable)"
			}
			name := item.Name
			if i == 0 {
				name = styled("› "+name, "1;36", color)
			} else {
				name = "  " + name
			}
			fmt.Fprintf(out, "  %d  %s%s\n       %s\n", i+1, name, suffix, item.Path)
		}
	}
	fmt.Fprintln(out, "\n  c  Create a journal\n  a  Connect an existing journal\n  r  Reconnect a moved journal\n  q  Cancel")
	for {
		fmt.Fprint(out, "\n  Choose: ")
		line, readErr := reader.ReadString('\n')
		choice := strings.TrimSpace(line)
		if readErr != nil && choice == "" {
			return "", errors.New("journal selection cancelled")
		}
		switch strings.ToLower(choice) {
		case "q":
			return "", errors.New("journal selection cancelled")
		case "r":
			if len(registry.Journals) == 0 {
				fmt.Fprintln(out, "  No registered journal to reconnect.")
				continue
			}
			index := 1
			if len(registry.Journals) > 1 {
				fmt.Fprint(out, "  Journal number: ")
				answer, err := reader.ReadString('\n')
				if err != nil && strings.TrimSpace(answer) == "" {
					return "", errors.New("journal selection cancelled")
				}
				index, err = strconv.Atoi(strings.TrimSpace(answer))
				if err != nil || index < 1 || index > len(registry.Journals) {
					fmt.Fprintln(out, "  Choose a listed journal number.")
					continue
				}
			}
			fmt.Fprint(out, "  New journal folder: ")
			answer, err := reader.ReadString('\n')
			if strings.TrimSpace(answer) == "" {
				if err != nil {
					return "", errors.New("journal selection cancelled")
				}
				fmt.Fprintln(out, "  Enter a folder path.")
				continue
			}
			path, err := filepath.Abs(strings.TrimSpace(answer))
			if err != nil {
				return "", err
			}
			if err := reconnectProject(registry.Journals[index-1].Path, path); err != nil {
				return "", err
			}
			return path, nil
		case "c", "a":
			fmt.Fprint(out, "  Journal folder: ")
			input, inputErr := reader.ReadString('\n')
			input = strings.TrimSpace(input)
			if input == "" {
				if inputErr != nil {
					return "", errors.New("journal selection cancelled")
				}
				fmt.Fprintln(out, "  Enter a folder path.")
				continue
			}
			path, err := filepath.Abs(input)
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
			return path, nil
		default:
			if choice == "" && len(registry.Journals) > 0 {
				choice = "1"
			}
			index, err := strconv.Atoi(choice)
			if err != nil || index < 1 || index > len(registry.Journals) {
				fmt.Fprintln(out, "  Choose a listed number, c, a, r, or q.")
				if readErr != nil {
					return "", errors.New("journal selection cancelled")
				}
				continue
			}
			item := registry.Journals[index-1]
			if !isJournal(item.Path) {
				return "", fmt.Errorf("journal is unavailable: %s; choose r to reconnect it or run `journal reconnect OLD_PATH NEW_PATH`", item.Path)
			}
			if err := rememberProject(item.Path); err != nil {
				return "", err
			}
			return item.Path, nil
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

func ask(reader *bufio.Reader, prompt string) (string, error) {
	fmt.Print(prompt)
	value, err := reader.ReadString('\n')
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	return strings.TrimRight(value, "\r\n"), nil
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
	registration, err := registrationPath(project)
	if err != nil {
		return "", err
	}
	filename := date.Format("2006-01-02") + "-" + safeComponent(title) + ".typ"
	target := filepath.Join(project, "entries", filename)
	relative := filepath.ToSlash(filepath.Join("entries", filename))
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
	file, err := os.OpenFile(target, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o644)
	if err != nil {
		if errors.Is(err, os.ErrExist) {
			return "", fmt.Errorf("entry already exists; nothing was changed: %s", target)
		}
		return "", err
	}
	if _, err := io.WriteString(file, content); err != nil {
		file.Close()
		os.Remove(target)
		return "", err
	}
	if err := file.Close(); err != nil {
		os.Remove(target)
		return "", err
	}
	if err := appendInclude(registration, relative); err != nil {
		os.Remove(target)
		return "", err
	}
	return target, nil
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
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	cmd := exec.CommandContext(ctx, typst, "compile", "--root", project, sourcePath, outputPath)
	result, err := cmd.CombinedOutput()
	if ctx.Err() != nil {
		return fmt.Errorf("validation of %s template timed out; no entry was created", kind)
	}
	if err != nil {
		return fmt.Errorf("cannot compile %s template; fix the template or journal setup and try again:\n%s", kind, strings.TrimSpace(string(result)))
	}
	return nil
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

func appendInclude(main, relative string) error {
	data, err := os.ReadFile(main)
	if err != nil {
		return err
	}
	text := string(data)
	line := "#include \"" + relative + "\""
	if hasLine(text, line) {
		return nil
	}
	if countLines(text, entriesMarker) != 1 {
		return fmt.Errorf("%s must contain exactly one %q line", main, entriesMarker)
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
	return atomicWrite(main, []byte(text), 0o644)
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
		args = append(args, "--reuse-window", project, entry)
	} else {
		args = append(args, entry)
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
	zipFile, err := os.Create(output)
	if err != nil {
		return err
	}
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
	fmt.Println("Starter ZIP written to", output)
	return nil
}
