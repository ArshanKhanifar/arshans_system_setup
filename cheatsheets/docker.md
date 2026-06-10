# Docker helpers

All container pickers use **fzf** multiselect unless noted.

| Command | Action |
|---------|--------|
| `docsh [pat]` | shell into container |
| `doclogs [pat]` | logs |
| `doclogsm [pat]` | logs multiselect |
| `docrm [pat]` | remove containers |
| `dockill [pat]` | kill containers |
| `docinspect [pat]` | inspect |
| `doctest [pat]` | pytest in container |
| `docrmall` | kill + rm all containers |
| `emlinux` | enter linux dev environment |

Pattern arg filters container names before fzf.
