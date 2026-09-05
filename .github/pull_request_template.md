**What changed**

**Verification run** (from AGENTS.md, cheapest first; name anything skipped)

- [ ] `python3 Scripts/validate.py`
- [ ] Generators rerun: catalog, Showcase manifest, site data
- [ ] `python3 -m unittest discover Tests/RegistryTests`
- [ ] Showcase builds; UI suite run if the change is visible
- [ ] Item recaptured with `Scripts/capture_previews.py` if its look changed

**Visual references**

A `GOLDEN-CHANGE` note in `docs/visual-testing.md` if a reference changed
