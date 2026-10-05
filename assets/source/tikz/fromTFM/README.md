# TikZ slide package for the ankle-exoskeleton TFM defense

This package contains **slide-optimised** TikZ versions of the thesis figures.
The goal is to preserve the scientific message while improving legibility for
16:9 presentation slides and projector use.

## Included slide figures

- `chap2_device_taxonomy_slides.tex`
- `chap2_scientific_positioning_slides.tex`
- `chap3_system_architecture_slides.tex`
- `chap3_foot_unit_inset_slides.tex`
- `chap3_tibial_unit_architecture_inset_slides.tex`
- `chap5_control_architecture_slides.tex`
- `chap6_rcp_architecture_slides.tex`

## Shared palette

All figures use `tikz_slide_palette.tex`, which defines:

- `archdark`, `archslate`, `archgold`, `archaqua`, ...
- subsystem colours:
  - `subsysTUFill`
  - `subsysFUFill`
  - `subsysATMFill`
  - `subsysACTFill`
  - `subsysELECFill`
  - `subsysCTRLFill`
  - `subsysEXPFill`

## Recommended use in the presentation

### Main-deck figures
- `chap2_scientific_positioning_slides`
- `chap3_system_architecture_slides`
- `chap5_control_architecture_slides`
- `chap6_rcp_architecture_slides`

### Support / comparison insets
- `chap3_foot_unit_inset_slides`
- `chap3_tibial_unit_architecture_inset_slides`

### Backup
- `chap2_device_taxonomy_slides`

## Build all PDFs

On Linux / macOS:

```bash
bash build/build_all.sh
```

On Windows PowerShell:

```powershell
Get-ChildItem .\standalone\*_standalone.tex |
  ForEach-Object { latexmk -pdf -interaction=nonstopmode $_.FullName }
```

The PDFs can then be converted to SVG, e.g. with Inkscape.

## Export to SVG (recommended workflow)

For each compiled PDF:

```bash
inkscape exported/pdf/chap3_system_architecture_slides.pdf \
  --export-type=svg \
  --export-filename=exported/svg/chap3_system_architecture_slides.svg
```

## Next adaptation targets for tables and dense figures

The following TFM elements should receive slide-specific adaptations next:

1. **Design-engineering requirements table**
   - highly abbreviated, colour-coded by subsystem / requirement family.
2. **Requirement fulfilment / discussion table**
   - compressed to key criteria, target, achieved behaviour, and conclusion.
3. **State-occupancy and transition-summary tables**
   - likely best presented as compact cards or heatmap-like summaries.
4. **Dense experimental summary tables**
   - reduce to the few metrics you will actually speak aloud.

For slide tables, reuse the same subsystem palette to preserve continuity
between architecture, diagrams, and evidence tables.
