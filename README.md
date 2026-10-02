# setup

Primo setup di un Mac per lavorare su Pelion, anche senza git installato.

```bash
curl -fsSL https://raw.githubusercontent.com/DiscenTech/setup/main/setup.sh | bash
```

Installa gli strumenti da riga di comando di Apple, Homebrew e GitHub CLI,
fa il login a GitHub nel browser, clona Pelion in ~/pelion e prosegue con
`scripts/bootstrap.sh` del repo.

## Con Claude Code

In una sessione di Claude Code (anche dal Desktop app) scrivi:

> Leggi https://raw.githubusercontent.com/DiscenTech/setup/main/claude-setup.md e seguilo.

Claude controlla il Mac, ti dice quando lanciare il comando qui sopra (per i
passi che chiedono la password e il browser), poi finisce il setup, avvia l'app
e ti spiega come entrare.

**Non modificare i file qui:** i sorgenti sono `scripts/setup.sh` e
`scripts/claude-setup.md` in DiscenTech/pelion; questa è la loro copia pubblica.
