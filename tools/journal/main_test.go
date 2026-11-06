package main

import (
	"bufio"
	"bytes"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestChooseJournalOffersRegisteredProjects(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	first, err := initProject(filepath.Join(root, "First"))
	if err != nil {
		t.Fatal(err)
	}
	second, err := initProject(filepath.Join(root, "Second"))
	if err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(first); err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(second); err != nil {
		t.Fatal(err)
	}
	var output bytes.Buffer
	selected, err := chooseJournal(bufio.NewReader(strings.NewReader("2\n")), &output)
	if err != nil || selected != first {
		t.Fatalf("selected %q: %v", selected, err)
	}
	if !strings.Contains(output.String(), "First") || !strings.Contains(output.String(), "Second") {
		t.Fatalf("missing choices: %s", &output)
	}
	registry, err := loadRegistry()
	if err != nil || registry.Journals[0].Path != first {
		t.Fatalf("selection not remembered: %+v %v", registry, err)
	}
}

func TestChooseJournalMissingPathIsNotSelected(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	if err := rememberProject(filepath.Join(root, "missing")); err != nil {
		t.Fatal(err)
	}
	var output bytes.Buffer
	_, err := chooseJournal(bufio.NewReader(strings.NewReader("1\n")), &output)
	if err == nil || !strings.Contains(err.Error(), "unavailable") {
		t.Fatalf("expected missing journal error: %v", err)
	}
}

func TestChooserReconnectsSingleMovedJournal(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	old, err := initProject(filepath.Join(root, "old"))
	if err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(old); err != nil {
		t.Fatal(err)
	}
	moved := filepath.Join(root, "moved")
	if err := os.Rename(old, moved); err != nil {
		t.Fatal(err)
	}
	var output bytes.Buffer
	got, err := chooseJournal(bufio.NewReader(strings.NewReader("r\n"+moved+"\n")), &output)
	if err != nil || got != moved {
		t.Fatalf("reconnect = %q, %v", got, err)
	}
	registry, err := loadRegistry()
	if err != nil || len(registry.Journals) != 1 || registry.Journals[0].Path != moved {
		t.Fatalf("registry = %+v, %v", registry, err)
	}
}

func TestChooserFormattingWorksWithoutColor(t *testing.T) {
	t.Setenv("NO_COLOR", "1")
	if terminalColor(os.Stdout) {
		t.Fatal("NO_COLOR must disable terminal colors")
	}
	if got := styled("Journal", "1;36", false); got != "Journal" {
		t.Fatalf("plain output = %q", got)
	}
	if got := styled("Journal", "1;36", true); !strings.Contains(got, "\x1b[0m") {
		t.Fatalf("highlight not reset: %q", got)
	}
}

func TestRuntimeUpdateDoesNotReplaceJournalFiles(t *testing.T) {
	project, err := initProject(filepath.Join(t.TempDir(), "journal"))
	if err != nil {
		t.Fatal(err)
	}
	custom := filepath.Join(project, "_satz", "local-note.txt")
	if err := os.WriteFile(custom, []byte("keep"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := run([]string{"update-satz", project}); err == nil {
		t.Fatal("unsafe runtime update should not run")
	}
	if data, err := os.ReadFile(custom); err != nil || string(data) != "keep" {
		t.Fatalf("runtime file changed: %q %v", data, err)
	}
}

func TestTypstEscapingAndKinds(t *testing.T) {
	got := typstString(`A "quote" \\ Δ`)
	if got != `"A \"quote\" \\\\ Δ"` {
		t.Fatalf("typstString() = %q", got)
	}
	for alias, want := range map[string]string{"m": "meeting", "s": "session", "n": "notes", "M": "meeting"} {
		if got := normalizeKind(alias); got != want {
			t.Errorf("normalizeKind(%q) = %q, want %q", alias, got, want)
		}
	}
	if !strings.Contains(scaffold("meeting"), "== Action Items") || strings.Contains(scaffold("meeting"), "== Goal") {
		t.Fatal("meeting scaffold is not the meeting template")
	}
	if !strings.Contains(scaffold("session"), "== Next Steps") || strings.Contains(scaffold("session"), "== Agenda") {
		t.Fatal("session scaffold is not the session template")
	}
}

func TestSplitCommandPreservesQuotedWindowsPath(t *testing.T) {
	got, err := splitCommand(`"C:\Program Files\Microsoft VS Code\bin\code.cmd" --wait`)
	if err != nil {
		t.Fatal(err)
	}
	want := []string{`C:\Program Files\Microsoft VS Code\bin\code.cmd`, "--wait"}
	if strings.Join(got, "\x00") != strings.Join(want, "\x00") {
		t.Fatalf("splitCommand() = %#v, want %#v", got, want)
	}
}

func TestWindowsCodeUsesExeWithoutShell(t *testing.T) {
	got, ok, err := editorCommand(`C:\My Journal`, `C:\My Journal\entries\x.typ`, `"C:\Program Files\Microsoft VS Code\bin\code.cmd"`, "windows", func(string) (string, error) {
		return `C:\Program Files\Microsoft VS Code\bin\code.cmd`, nil
	}, func(path string) (os.FileInfo, error) {
		if path != `C:/Program Files/Microsoft VS Code/Code.exe` {
			t.Fatalf("unexpected Code.exe path %q", path)
		}
		return fakeFileInfo{}, nil
	})
	if err != nil || !ok {
		t.Fatalf("editorCommand() = (%v, %v, %v)", got, ok, err)
	}
	wantExe := `C:/Program Files/Microsoft VS Code/Code.exe`
	if got[0] != wantExe {
		t.Fatalf("executable = %q, want %q", got[0], wantExe)
	}
	if got[1] != "--reuse-window" || got[2] != `C:\My Journal` || got[3] != `C:\My Journal\entries\x.typ` {
		t.Fatalf("unexpected editor args: %#v", got)
	}
	if strings.HasSuffix(strings.ToLower(got[0]), ".cmd") || strings.HasSuffix(strings.ToLower(got[0]), ".bat") {
		t.Fatal("Windows command shim must never be invoked")
	}
}

func TestCreateEntryIsSafeAndUpdatesIncludes(t *testing.T) {
	project := t.TempDir()
	if _, err := initProject(filepath.Join(project, "My Journal")); err != nil {
		t.Fatal(err)
	}
	project = filepath.Join(project, "My Journal")
	mainBefore, err := os.ReadFile(filepath.Join(project, "main.typ"))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := createEntry(project, "  ", "meeting", "", time.Now()); err == nil {
		t.Fatal("empty title should fail")
	}
	if _, err := createEntry(project, "Title", "invalid", "", time.Now()); err == nil {
		t.Fatal("invalid kind should fail")
	}
	mainAfter, _ := os.ReadFile(filepath.Join(project, "main.typ"))
	if string(mainBefore) != string(mainAfter) {
		t.Fatal("invalid input modified the journal")
	}
	date := time.Date(2026, 10, 21, 0, 0, 0, 0, time.UTC)
	title := `Quoted "title" \\ Δ`
	entry, err := createEntry(project, title, "meeting", "alpha, β", date)
	if err != nil {
		t.Fatal(err)
	}
	content, err := os.ReadFile(entry)
	if err != nil {
		t.Fatal(err)
	}
	for _, text := range []string{`title: "Quoted \"title\" \\\\ Δ"`, `keywords: "alpha, β"`, "== Agenda", "== What we talked about", "== Action Items"} {
		if !strings.Contains(string(content), text) {
			t.Errorf("entry does not contain %q", text)
		}
	}
	mainAfter, err = os.ReadFile(filepath.Join(project, "main.typ"))
	if err != nil {
		t.Fatal(err)
	}
	entryList, err := os.ReadFile(filepath.Join(project, "journal-entries.typ"))
	if err != nil || !strings.Contains(string(entryList), `#include "entries/2026-10-21-quoted-title-δ.typ"`) {
		t.Fatalf("entry list missing generated include: %s (%v)", entryList, err)
	}
	if _, err := createEntry(project, title, "meeting", "", date); err == nil {
		t.Fatal("duplicate entry should not overwrite")
	}
	contentAfter, _ := os.ReadFile(entry)
	if string(content) != string(contentAfter) {
		t.Fatal("duplicate entry changed the original")
	}
}

func TestMissingEntryListLinkLeavesJournalUntouched(t *testing.T) {
	project, err := initProject(filepath.Join(t.TempDir(), "journal"))
	if err != nil {
		t.Fatal(err)
	}
	mainPath := filepath.Join(project, "main.typ")
	main, err := os.ReadFile(mainPath)
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(mainPath, []byte(strings.Replace(string(main), `#include "journal-entries.typ"`, "", 1)), 0o644); err != nil {
		t.Fatal(err)
	}
	listPath := filepath.Join(project, "journal-entries.typ")
	before, err := os.ReadFile(listPath)
	if err != nil {
		t.Fatal(err)
	}
	_, err = createEntry(project, "Disconnected", "notes", "", time.Now())
	if err == nil || !strings.Contains(err.Error(), "journal-entries.typ") {
		t.Fatalf("expected actionable missing link error, got %v", err)
	}
	after, _ := os.ReadFile(listPath)
	if string(before) != string(after) {
		t.Fatal("entry list changed")
	}
	entries, _ := os.ReadDir(filepath.Join(project, "entries"))
	if len(entries) != 1 {
		t.Fatalf("entry unexpectedly created: %v", entries)
	}
}

func TestRegistrationRequiresRealMarkerAndSetup(t *testing.T) {
	project, err := initProject(filepath.Join(t.TempDir(), "journal"))
	if err != nil {
		t.Fatal(err)
	}
	list := filepath.Join(project, "journal-entries.typ")
	data, err := os.ReadFile(list)
	if err != nil {
		t.Fatal(err)
	}
	// A substring inside another comment is not a usable marker.
	broken := strings.Replace(string(data), entriesMarker, "// example: "+entriesMarker, 1)
	if err := os.WriteFile(list, []byte(broken), 0o644); err != nil {
		t.Fatal(err)
	}
	if _, err := createEntry(project, "Not registered", "notes", "", time.Now()); err == nil {
		t.Fatal("commented marker accepted")
	}
	if err := os.WriteFile(list, data, 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Remove(filepath.Join(project, "setup.typ")); err != nil {
		t.Fatal(err)
	}
	if _, err := createEntry(project, "No setup", "notes", "", time.Now()); err == nil || !strings.Contains(err.Error(), "setup.typ") {
		t.Fatalf("missing setup not diagnosed: %v", err)
	}
}

func TestMissingEntryListReportsRecovery(t *testing.T) {
	project, err := initProject(filepath.Join(t.TempDir(), "journal"))
	if err != nil {
		t.Fatal(err)
	}
	if err := os.Remove(filepath.Join(project, "journal-entries.typ")); err != nil {
		t.Fatal(err)
	}
	_, err = createEntry(project, "Not saved", "notes", "", time.Now())
	if err == nil || !strings.Contains(err.Error(), "journal-entries.typ") {
		t.Fatalf("missing entry list not diagnosed: %v", err)
	}
}

func TestEditableEntryTemplates(t *testing.T) {
	project, err := initProject(filepath.Join(t.TempDir(), "journal"))
	if err != nil {
		t.Fatal(err)
	}
	template := filepath.Join(project, "templates", "meeting.typ")
	if err := os.WriteFile(template, []byte("  == My meeting notes\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	entry, err := createEntry(project, "Custom", "meeting", "", time.Now())
	if err != nil {
		t.Fatal(err)
	}
	content, err := os.ReadFile(entry)
	if err != nil || !strings.Contains(string(content), "== My meeting notes") {
		t.Fatalf("custom template not used: %s (%v)", content, err)
	}
	if err := os.Remove(template); err != nil {
		t.Fatal(err)
	}
	if _, err := createEntry(project, "Missing", "meeting", "", time.Now()); err == nil {
		t.Fatal("missing template should fail")
	}
	if _, err := os.Stat(filepath.Join(project, "entries", time.Now().Format("2006-01-02")+"-missing.typ")); !os.IsNotExist(err) {
		t.Fatalf("failed creation left an entry: %v", err)
	}
}

func TestLoadProjectPrefersCurrentJournalToRemembered(t *testing.T) {
	root := t.TempDir()
	remembered := filepath.Join(root, "remembered")
	current := filepath.Join(root, "current")
	for _, project := range []string{remembered, current} {
		if _, err := initProject(project); err != nil {
			t.Fatal(err)
		}
	}
	config := filepath.Join(root, "isolated-config")
	t.Setenv("JOURNAL_CONFIG_DIR", config)
	if err := rememberProject(remembered); err != nil {
		t.Fatal(err)
	}
	old, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	if err := os.Chdir(current); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = os.Chdir(old) })
	got, err := loadProject("")
	if err != nil {
		t.Fatal(err)
	}
	gotResolved, _ := filepath.EvalSymlinks(got)
	currentResolved, _ := filepath.EvalSymlinks(current)
	if gotResolved != currentResolved {
		t.Fatalf("loadProject() = %q, want current project %q", got, current)
	}
}

func TestRegistryMigratesAndKeepsMultipleJournals(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	first, err := initProject(filepath.Join(root, "First"))
	if err != nil {
		t.Fatal(err)
	}
	second, err := initProject(filepath.Join(root, "Second"))
	if err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(configDir(), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(configDir(), "project.json"), []byte(`{"path":`+typstString(first)+`}`), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(second); err != nil {
		t.Fatal(err)
	}
	registry, err := loadRegistry()
	if err != nil {
		t.Fatal(err)
	}
	if len(registry.Journals) != 2 || registry.Journals[0].Path != second || registry.Journals[1].Path != first {
		t.Fatalf("unexpected migrated registry: %+v", registry)
	}
	if err := rememberProject(first); err != nil {
		t.Fatal(err)
	}
	registry, err = loadRegistry()
	if err != nil {
		t.Fatal(err)
	}
	if len(registry.Journals) != 2 || registry.Journals[0].Path != first {
		t.Fatalf("selection duplicated or lost a journal: %+v", registry)
	}
}

func TestReconnectMovedJournalPreservesOtherRegistrations(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	first, err := initProject(filepath.Join(root, "First"))
	if err != nil {
		t.Fatal(err)
	}
	second, err := initProject(filepath.Join(root, "Second"))
	if err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(first); err != nil {
		t.Fatal(err)
	}
	if err := rememberProject(second); err != nil {
		t.Fatal(err)
	}
	moved := filepath.Join(root, "Moved")
	if err := os.Rename(first, moved); err != nil {
		t.Fatal(err)
	}
	if err := reconnectProject(first, moved); err != nil {
		t.Fatal(err)
	}
	registry, err := loadRegistry()
	if err != nil {
		t.Fatal(err)
	}
	if len(registry.Journals) != 2 || registry.Journals[0].Path != moved || registry.Journals[1].Path != second {
		t.Fatalf("unexpected registry: %+v", registry)
	}
	if err := reconnectProject(second, moved); err == nil {
		t.Fatal("reconnecting to an already registered journal must fail")
	}
}

func TestConnectRejectsIncompleteJournal(t *testing.T) {
	root := t.TempDir()
	t.Setenv("JOURNAL_CONFIG_DIR", filepath.Join(root, "config"))
	if err := os.Mkdir(filepath.Join(root, "entries"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(root, "main.typ"), []byte("Hello"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := run([]string{"use", root}); err == nil || !strings.Contains(err.Error(), "setup.typ") {
		t.Fatalf("incomplete journal accepted: %v", err)
	}
	registry, err := loadRegistry()
	if err != nil || len(registry.Journals) != 0 {
		t.Fatalf("registry changed: %+v %v", registry, err)
	}
}

type fakeFileInfo struct{}

func (fakeFileInfo) Name() string       { return "Code.exe" }
func (fakeFileInfo) Size() int64        { return 1 }
func (fakeFileInfo) Mode() os.FileMode  { return 0o755 }
func (fakeFileInfo) ModTime() time.Time { return time.Time{} }
func (fakeFileInfo) IsDir() bool        { return false }
func (fakeFileInfo) Sys() any           { return nil }

func TestGeneratedStarterAndEscapedEntryCompile(t *testing.T) {
	typst, err := exec.LookPath("typst")
	if err != nil {
		t.Skip("Typst is not installed")
	}
	parent := t.TempDir()
	project, err := initProject(filepath.Join(parent, "My Journal"))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := createEntry(project, `Quoted "title" \\ Δ`, "meeting", "alpha, β", time.Now()); err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command(typst, "compile", "--root", project, filepath.Join(project, "main.typ"), filepath.Join(parent, "journal.pdf"))
	if output, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("typst compile failed: %v\n%s", err, output)
	}
	if info, err := os.Stat(filepath.Join(parent, "journal.pdf")); err != nil || info.Size() == 0 {
		t.Fatalf("compiled PDF missing or empty: info=%v err=%v", info, err)
	}
	configPath := filepath.Join(project, "config.typ")
	config, err := os.ReadFile(configPath)
	if err != nil {
		t.Fatal(err)
	}
	configText := strings.Replace(string(config), `theme: "neutral"`, `theme: "plum"`, 1)
	configText = strings.Replace(configText, `paper: "a4"`, `paper: "iso-b5"`, 1)
	if err := os.WriteFile(configPath, []byte(configText), 0o644); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(configText, "\n#let journal-overrides = (:)") {
		t.Fatal("starter config should leave Satz typography defaults live")
	}
	setup, err := os.ReadFile(filepath.Join(project, "setup.typ"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(setup), "merge((page: (paper: journal-style.paper,)), journal-overrides)") {
		t.Fatal("starter setup should pass only paper and explicit overrides to Satz")
	}
	compileSVG := func(prefix string) {
		t.Helper()
		cmd := exec.Command(typst, "compile", "--root", project, "--format", "svg", filepath.Join(project, "main.typ"), filepath.Join(parent, prefix+"-{p}.svg"))
		if output, err := cmd.CombinedOutput(); err != nil {
			t.Fatalf("typst SVG compile failed: %v\n%s", err, output)
		}
	}
	compileSVG("before")
	coverSVG, err := os.ReadFile(filepath.Join(parent, "before-1.svg"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(coverSVG), `viewBox="0 0 498.897637795 708.661417323"`) {
		t.Fatalf("iso-b5 cover size missing from SVG: %s", coverSVG[:min(len(coverSVG), 200)])
	}
	entrySVG, err := os.ReadFile(filepath.Join(parent, "before-3.svg"))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(entrySVG), "#674666") {
		t.Fatal("plum heading color is missing from generated entry")
	}
	version, err := os.ReadFile(filepath.Join(project, "_satz", "VERSION.txt"))
	if err != nil || !strings.Contains(string(version), "Satz 0.2.0") {
		t.Fatalf("starter must record Satz 0.2.0: %q, %v", version, err)
	}
	defaultsPath := filepath.Join(project, "_satz", "journal", "defaults.typ")
	defaults, err := os.ReadFile(defaultsPath)
	if err != nil {
		t.Fatal(err)
	}
	changedDefaults := strings.Replace(string(defaults), "    size: 11pt,", "    size: 17pt,", 1)
	if changedDefaults == string(defaults) {
		t.Fatal("test could not locate bundled heading default")
	}
	if err := os.WriteFile(defaultsPath, []byte(changedDefaults), 0o644); err != nil {
		t.Fatal(err)
	}
	compileSVG("after")
	changedEntrySVG, err := os.ReadFile(filepath.Join(parent, "after-3.svg"))
	if err != nil {
		t.Fatal(err)
	}
	if string(entrySVG) == string(changedEntrySVG) {
		t.Fatal("changing the Satz heading default did not change the generated journal")
	}
}
