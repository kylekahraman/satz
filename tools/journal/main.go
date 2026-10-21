// Journal is a standalone cross-platform starter and entry helper for Satz.
package main

import (
	"archive/zip"
	"bufio"
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
	"strings"
	"time"
	"unicode"
)

//go:embed runtime templates
var assets embed.FS

const entriesMarker = "// --- end entries ---"

type settings struct {
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
		if !isJournal(path) {
			return fmt.Errorf("not a journal project (expected main.typ and entries/): %s", path)
		}
		if err := rememberProject(path); err != nil {
			return err
		}
		fmt.Println("Journal selected:", path)
		return nil
	case "update-satz":
		path := "."
		if len(args) > 2 {
			return errors.New("usage: journal update-satz [PATH]")
		}
		if len(args) == 2 {
			path = args[1]
		}
		return updateRuntime(path)
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
  journal update-satz [PATH]    Refresh _satz/ from this executable's runtime
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
	for _, dir := range []string{"entries", ".vscode"} {
		if err := os.MkdirAll(filepath.Join(destination, dir), 0o755); err != nil {
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
	mainPath := filepath.Join(destination, "main.typ")
	mainBytes, err := os.ReadFile(mainPath)
	if err != nil {
		return "", err
	}
	if err := os.WriteFile(mainPath, []byte(strings.ReplaceAll(string(mainBytes), "{{FIRST_ENTRY_PATH}}", entryPath)), 0o644); err != nil {
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

Edit ` + "`config.typ`" + ` to personalize the cover and journal style. Change the title, subtitle, author, theme, cover layout, and paper size there. Available themes include ` + "`neutral`" + `, ` + "`soft-jade`" + `, ` + "`soft-slate`" + `, ` + "`warm-editorial`" + `, ` + "`plum`" + `, and ` + "`soft-rose`" + `. Add new entries under ` + "`entries/`" + ` and include them in ` + "`main.typ`" + ` between its entry markers.

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

func updateRuntime(path string) error {
	project, err := filepath.Abs(path)
	if err != nil {
		return err
	}
	if !isJournal(project) {
		return fmt.Errorf("not a journal project: %s", project)
	}
	target := filepath.Join(project, "_satz")
	if err := os.RemoveAll(target); err != nil {
		return err
	}
	if err := copyEmbeddedDir("runtime", target); err != nil {
		return err
	}
	fmt.Println("Updated Satz runtime in", target)
	return nil
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
	if err := os.MkdirAll(configDir(), 0o755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(settings{Path: path}, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(configDir(), "project.json"), data, 0o600)
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
	data, err := os.ReadFile(filepath.Join(configDir(), "project.json"))
	if err == nil {
		var saved settings
		if err := json.Unmarshal(data, &saved); err != nil {
			return "", err
		}
		if isJournal(saved.Path) {
			return saved.Path, nil
		}
	}
	return "", errors.New("no journal selected; run `journal init PATH`, `journal use PATH`, or run from a journal folder")
}

func newEntry(path, editor string) error {
	project, err := loadProject(path)
	if err != nil {
		return err
	}
	fmt.Println("Selected journal:", project)
	reader := bufio.NewReader(os.Stdin)
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
	main := filepath.Join(project, "main.typ")
	mainBytes, err := os.ReadFile(main)
	if err != nil {
		return "", fmt.Errorf("not a journal project: %w", err)
	}
	if _, err := os.Stat(filepath.Join(project, "entries")); err != nil {
		return "", fmt.Errorf("not a journal project: entries/: %w", err)
	}
	if !strings.Contains(string(mainBytes), entriesMarker) {
		return "", fmt.Errorf("%s is missing entries marker %q", main, entriesMarker)
	}
	filename := date.Format("2006-01-02") + "-" + safeComponent(title) + ".typ"
	target := filepath.Join(project, "entries", filename)
	relative := filepath.ToSlash(filepath.Join("entries", filename))
	sections := scaffold(kind)
	content := "#import \"../setup.typ\": journal-entry\n\n" +
		"#journal-entry(\n" +
		"  title: " + typstString(title) + ",\n" +
		"  date: " + typstString(date.Format("Monday, 02/01/2006")) + ",\n" +
		"  keywords: " + typstString(keywords) + ",\n" +
		")[\n" + sections + "]\n"
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
	if err := appendInclude(main, relative); err != nil {
		os.Remove(target)
		return "", err
	}
	return target, nil
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
	if strings.Contains(text, line) {
		return nil
	}
	if !strings.Contains(text, entriesMarker) {
		return fmt.Errorf("%s is missing entries marker %q", main, entriesMarker)
	}
	text = strings.Replace(text, entriesMarker, line+"\n"+entriesMarker, 1)
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
