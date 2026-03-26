# Project Bundle Sharing

Export and import self-contained `.soundboard` project bundles for sharing across devices and users.

## Bundle Format

A `.soundboard` file is a ZIP archive:

```
MyProject.soundboard (zip)
├── project.json        ← Project struct (same format as ProjectManager)
└── audio/
    ├── kick.wav
    ├── snare.wav
    └── ...
```

All audio files referenced by the project's pad configurations are included. Factory samples are included too — the receiving device may not have generated them yet.

## UTType Registration

- Identifier: `com.soundboard.project`
- Conforms to: `public.data`, `public.zip-archive`
- Extension: `.soundboard`
- Description: "Soundboard Project"

Registered in Info.plist so both platforms handle the file natively (double-click on macOS, tap in Files on iOS, AirDrop on both).

## Export Flow

1. User taps **Export** button next to a project in Settings > Projects tab.
2. `SoundboardBundle.export(project:sampleStore:)` creates a temp directory, writes `project.json`, copies all referenced audio files into `audio/`, and zips the result into a `.soundboard` file.
3. On macOS: `NSSavePanel` with suggested filename `{project.name}.soundboard`.
4. On iOS: `ShareLink` / `UIActivityViewController` with the temp file URL.
5. Temp file is cleaned up after the share completes.

## Import Flow

1. User opens a `.soundboard` file via:
   - Finder / Files app (UTType registration triggers `.onOpenURL`)
   - AirDrop
   - **Import** button in Settings > Projects tab (presents file picker filtered to `.soundboard`)
2. `SoundboardBundle.import(from:sampleStore:projectManager:)`:
   a. Unzips to a temp directory.
   b. Decodes `project.json` into a `Project` struct.
   c. Checks for name collision via `projectManager.findByName(_:)`.
3. If a project with the same name exists:
   - Alert with two options: **"Replace"** (overwrites the existing project) or **"Keep Both"** (appends " Copy" to the imported project's name, generates a new UUID).
   - If no collision, proceeds directly.
4. Copies audio files from the bundle's `audio/` directory into `sampleStore.audioDirectory`. Files that already exist on disk (same filename + same size) are skipped to avoid duplicates.
5. Saves the project via `projectManager.save(_:)` and switches to it.

## Error Handling

- Invalid/corrupt ZIP: alert "Could not open project file."
- Missing `project.json` inside ZIP: alert "This file doesn't contain a valid Soundboard project."
- Missing audio files referenced by pads: import succeeds but affected pads show as empty (graceful degradation, same as if a sample file were deleted locally).

## Files to Create

| File | Purpose |
|------|---------|
| `Managers/SoundboardBundle.swift` | `export()` and `import()` static methods handling ZIP pack/unpack, file copying, duplicate detection |

## Files to Modify

| File | Change |
|------|--------|
| `Info.plist` | Add exported/imported UTType declaration for `com.soundboard.project` |
| `project.yml` | Add UTType info in settings if needed by XcodeGen |
| `ProjectManager.swift` | Add `findByName(_:) -> ProjectMetadata?` helper |
| `SettingsView.swift` | Add Export/Import buttons per project in Projects tab |
| `SoundboardApp.swift` | Add `.onOpenURL` handler to trigger import when a `.soundboard` file is opened |
| `AppState.swift` | Add `importProject(from:)` method coordinating the import flow + state for import alert |

## Bundle Size Considerations

Audio files are WAV (uncompressed). A typical project with 20 samples at ~5s each is roughly 10 MB. ZIP compression on WAV yields ~10-20% savings. This is acceptable for AirDrop/file sharing. No special compression beyond ZIP is needed.
