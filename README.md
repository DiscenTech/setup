# setup

Primo setup di un Mac per lavorare su Pelion, anche senza git installato.

```bash
curl -fsSL https://raw.githubusercontent.com/DiscenTech/setup/main/setup.sh | bash
```

Installa gli strumenti da riga di comando di Apple, Homebrew e GitHub CLI,
fa il login a GitHub nel browser, clona Pelion in ~/pelion e prosegue con
`scripts/bootstrap.sh` del repo.

**Non modificare setup.sh qui:** il sorgente è `scripts/setup.sh` in
DiscenTech/pelion; questa è la sua copia pubblica.
