# sc-im source patches

Base commit: **b564571** (upstream `master`)

| # | patch | what |
|---|-------|------|
| 01 | `01-open-xlsx-crash-fix.patch` | heap use-after-free opening multi-sheet xlsx: null the vacated last row in `int_deleterow` and null-guard empty cell content in the xlsx reader |
| 02 | `02-open-path-metachars.patch` | open files whose path holds shell metachars/spaces/parens: try the literal path before `wordexp` in `load_tbl` |
| 03 | `03-cursorline.patch` | `set show_cursor` also draws a full-width underline above and below the current row |
| 04 | `04-sheet-tab-bar.patch` | sheet header shows `[idx/total]` and windows the `{name}` tabs around the current sheet with `<`/`>` on overflow |
| 05 | `05-partial-last-column.patch` | a column too wide for the space left is drawn clipped at the right edge instead of dropped, leaving the space blank |

## Apply

```sh
./apply.sh /path/to/sc-im
cd /path/to/sc-im/src
make YACC='bison -y'
make install prefix=$HOME/.local
```

03/04 are gated on `set show_cursor`
