# Phase A oracle fixtures

`schema.json` and `preset_vectors.json` are byte copies of the canonical schema and the shared Python, website, and Showcase codec vectors. `fixturesMatchCanonicalContracts` rejects drift between the copies and the originals. Phase C moves the vectors to their final shared home before deleting the Python test directory

`validation-cases.json` records 45 distinct calls made by the unchanged `test_validation.py` suite at 0d353ed. Each entry carries the test name, registry files, scope, and the Python validator's exact ordered issues. The Swift tests load the files into an in-memory filesystem, parse the real validate command, and compare its exit status and both output streams. A malformed fixture cannot pass by merely throwing an unrelated error

`diff-cases.json` records 106 Python `difflib.unified_diff` results with three context lines. The cases cover insertions, deletions, replacements, repeated lines, empty files, missing final newlines, CRLF, other splitlines boundaries, and SequenceMatcher's autojunk threshold. The random cases use a fixed Python seed of 42

The inline installation, merge, and conflict directory snapshots in `Commands.swift` and `InstallerSafetyTests.swift` were produced by `Scripts/install.py`. They include every directory, owned source byte, receipt byte, base byte, and conflict artifact. `PresetCommandSnapshots.swift` takes its expected text from `Scripts/preset.py`

`Scripts/check_swift_parity.py` is the temporary subprocess proof for Phase A and Phase B. It copies the registry into a temporary clone, compares stdout, stderr, and exit status, then compares complete destination trees without normalizing file contents. Its interoperability cases start both destinations with a Python receipt, then with a Swift receipt, and update each with both tools
