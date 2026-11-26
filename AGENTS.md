# AGENTS.md - installeur

La routine de maintenance de ce dépôt, pour un agent : elle se lit avant chaque changement, et chaque pull request la suit.
`CLAUDE.md` est un lien symbolique vers ce fichier.
Le README dit ce que fait l'installeur ; ce fichier dit comment le garder sain.

## Ce que ce dépôt possède

- L'amorçage du Mac d'une personne qui rejoint WaveProm, `bin/installer.sh` : Homebrew, gh, la connexion à GitHub, l'invitation à WaveProm, l'identité git, un clone par dépôt de l'organisation dans `~/.waveprom`, leur vérification, et le passage de main au système.
- La porte d'entrée : la phrase « Installe github.com/WaveProm/installeur », la première ligne du README qui envoie Claude Code à l'en-tête du script, et l'URL raw de cet en-tête, `https://raw.githubusercontent.com/WaveProm/installeur/main/bin/installer.sh`.

## Ce qu'il ne possède pas

- Tout ce qui suit les clones, que détaillent l'en-tête de `bin/configurer.sh` et le README du système : les consignes de l'agence, les skills, et tout ce que Claude Code doit trouver à chaque session.
  `bin/configurer.sh` du dépôt privé WaveProm/onboarding-integration-continue-waveprom les possède, et les tient à jour seul à chaque session.
- La liste des dépôts clonés : c'est celle de l'organisation WaveProm sur GitHub.
- Le choix du rôle d'une personne : un owner le fixe en l'invitant.

## Le contrat avec le système

Le seul contrat : le dépôt privé WaveProm/onboarding-integration-continue-waveprom se clone dans `~/.waveprom/onboarding-integration-continue-waveprom`, et l'étape 8 y lance `bin/configurer.sh`, avec `--dev` en mode dev ou sans argument.
`SYSTEM_CLONE` et `CONFIGURER`, en tête de `bin/installer.sh`, portent ces deux noms, et rien d'autre dans ce dépôt ne nomme un fichier du système.
Changer l'un des deux exige la même modification dans l'autre dépôt, le même jour, par deux pull requests qui se citent et se fusionnent ensemble.
L'installeur laisse au système ce qu'il suppose : Homebrew sous `/opt/homebrew`, git, et gh connecté à GitHub.

## Avant chaque pull request

Chaque commande tourne depuis la racine du clone de la branche, et sa sortie va dans le corps de la pull request.

1. `shellcheck bin/installer.sh` ne signale rien.
2. Deux runs de développement sur un même HOME temporaire finissent sur « C'est prêt. », le second avec « déjà » à chaque étape, configuration comprise :
   ```
   H=$(mktemp -d)
   HOME=$H GH_TOKEN=$(gh auth token) /bin/bash bin/installer.sh --dev
   HOME=$H GH_TOKEN=$(gh auth token) /bin/bash bin/installer.sh --dev
   ls -l "$H/.claude/CLAUDE.md"
   jq .hooks.SessionStart "$H/.claude/settings.json"
   ```
   Tant qu'une pull request du système n'est pas fusionnée, son clone se pose d'abord sur sa branche :
   `git clone -q -b <branche> https://github.com/WaveProm/onboarding-integration-continue-waveprom.git "$H/.waveprom/onboarding-integration-continue-waveprom"`.
3. `bin/installer.sh --help` imprime l'en-tête, et `curl -fsSL` de l'URL raw imprime le même script une fois la branche fusionnée.
4. Le refus sur le Mac d'un associé tient : avec `mkdir "$A/.hypnos"`, `HOME=$A /bin/bash bin/installer.sh --dev` sort en 3 et `ls -A "$A"` ne montre que `.hypnos`.
5. `grep -rn 'onboarding-integration-continue-waveprom' --exclude-dir=.git .` ne trouve que le contrat, le nom du système et l'historique du journal et de la preuve.

## Les règles qui gardent l'installeur sain

- Chaque étape reste idempotente : relancé sur un Mac installé, l'installeur ne change rien et le dit à chaque étape.
- Une personne déjà installée n'est jamais cassée : un changement tient sur un Mac installé par la version de `main`.
- Ce dépôt est public : il ne porte ni secret, ni donnée d'un client, ni rien qui ne se lise par tous.
- L'installeur ne lit rien du dépôt privé avant la connexion à GitHub de l'étape 3.
- Ce qui peut vivre dans le système y va : l'installeur ne grandit que pour amener un Mac jusqu'aux clones.
- L'URL raw, la phrase d'entrée et la première ligne du README changent ensemble.
- Le script garde son en-tête sous le shebang à jour : la commande pour Claude Code, l'usage, le contrat, les étapes, la sortie, les codes de sortie.
- Le code suit /code-methodologie : une preuve `SSOP-<sujet>.md` à la racine avant le code, et une ligne de `project-level-past-decisions-log.md` par problème tranché.
