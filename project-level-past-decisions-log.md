# Past decisions

Append only. One row per decision. A row is never edited or deleted, a reversal is a new row.

A row exists when a problem was raised and a decision closed it. Nothing else gets a row.
Problem and decision are one line each. An error code, a trace id or a ticket number goes in Ref, never the error itself.

| Date | Problem | Decision | Ref |
| ---- | ------- | -------- | --- |
| 2026-11-26 | L'installeur arrive par curl avant que git existe, il ne peut charger aucun autre fichier du dépôt | installer.sh tient en un seul fichier, chaque décision dans sa fonction, `main "$@"` en dernière ligne | inbox 001 |
| 2026-11-26 | La règle maison interdit les commentaires, l'humain veut les instructions pour Claude Code dans le script | Un en-tête de commentaires sous le shebang, sur le modèle de ~/.hypnos/bin, imprimé par --help | inbox 003 |
| 2026-11-26 | Homebrew, gh et git impriment des centaines de lignes, chaque étape ne doit en imprimer qu'une | Leur sortie va dans ~/Library/Logs/WaveProm/installer.log, que nomme chaque ligne d'échec | - |
| 2026-11-26 | L'install.sh de Homebrew n'écrit pas ~/.zprofile, et Claude Code ne trouve rien sous /opt/homebrew/bin sans lui | L'étape 1 ajoute `eval "$(/opt/homebrew/bin/brew shellenv zsh)"` à ~/.zprofile, au motif que teste install.sh | install.sh:1167 |
| 2026-11-26 | Quels scopes demander à la connexion GitHub | `repo` seul, que X-Accepted-OAuth-Scopes accepte sur GET et PATCH /user/memberships/orgs/WaveProm, et que demandent la liste et le clone des dépôts privés | X-Accepted-OAuth-Scopes |
| 2026-11-26 | Le Mac de dev a le gh du tap automic-vault/isotopes, `brew list gh` le dirait absent et `brew install gh` entrerait en conflit | L'étape 2 teste `command -v gh` | - |
| 2026-11-26 | Un clone coupé laisserait dans ~/.waveprom un dossier qui ressemble à un clone | Le clone se fait dans ~/.waveprom.partial, puis se déplace dans ~/.waveprom | - |
| 2026-11-26 | Le délai par défaut de l'outil Bash, 2 minutes, est plus court que l'installation des Command Line Tools | L'en-tête demande à Claude Code le délai maximal, 600000 ms | - |
| 2026-11-26 | Quel rôle la vérification finale attend | admin, le rôle de l'invitation du protocole | PROTOCOLE-onboarding-github.md, étape 2 |
| 2026-11-26 | Exiger le rôle admin ferait échouer un consultant invité comme membre | L'étape 8 vérifie l'adhésion active et l'écriture sur chaque dépôt, quel que soit le rôle, que l'owner choisit à l'invitation | inbox 004 |
| 2026-11-26 | Le dépôt change de nom, et l'URL raw de la commande d'entrée avec lui | Chaque mention du dépôt, URL raw comprise, porte WaveProm/onboarding-integration-continue-waveprom | inbox 006 |
| 2026-11-26 | Avant la fusion, main ne porte ni le gabarit ni le script, et la vérification d'un run de développement échoue sur un clone frais | Le run de preuve part d'un HOME où le clone de ce dépôt est déjà posé sur la branche de la pull request | - |
| 2026-11-26 | Sur le Mac d'un associé, l'étape 8 déplacerait son ~/.claude/CLAUDE.md, lien vers ses consignes globales | L'installeur refuse de tourner quand ~/.hypnos existe, avant toute étape et sans rien toucher, code de sortie 3 | inbox 002 |
| 2026-11-26 | L'installeur doit se lire avant la connexion à GitHub, et le système de l'agence rester réservé à ses membres | L'amorçage vit seul dans ce dépôt public, sous bin/installer.sh ; l'URL raw et la phrase « Installe github.com/WaveProm/installeur » le suivent, et le système reste dans le dépôt privé WaveProm/onboarding-integration-continue-waveprom | brief, commit 375cbf6 |
| 2026-11-26 | Tout ce que l'installeur posait après les clones change avec le système, et n'atteignait une personne qu'en relançant l'installeur | L'installeur s'arrête aux clones et à leur vérification, puis passe la main à bin/configurer.sh du système, qui possède le reste et se relance seul à chaque session | inbox 001 |
| 2026-11-26 | Deux dépôts qui se connaissent divergent en silence | Le seul contrat : le système se clone dans ~/.waveprom/onboarding-integration-continue-waveprom et y expose bin/configurer.sh ; changer l'un des deux exige la même modification dans l'autre dépôt, le même jour | inbox 001 |
| 2026-11-26 | Tant que la pull request du système n'est pas fusionnée, son main ne porte pas bin/configurer.sh, et l'étape 7 échoue sur un clone frais | Le run de preuve part d'un HOME où le clone du système est déjà posé sur la branche de sa pull request | - |
