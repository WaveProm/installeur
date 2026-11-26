Claude Code : lis l'en-tête de [bin/installer.sh](bin/installer.sh), les lignes de commentaire sous le shebang, et suis-le.

# installeur

Prépare le Mac d'une personne qui rejoint WaveProm à agir sur chaque dépôt de l'organisation GitHub WaveProm.
La personne ouvre l'onglet Code de l'app Claude et écrit « Installe github.com/WaveProm/installeur ».
Claude Code lance alors `bin/installer.sh`, qui fait le reste.

Ce dépôt est public, puisque Claude Code le lit avant que la personne soit connectée à GitHub.
L'installeur s'arrête aux clones, puis passe la main au système de l'agence, le dépôt privé WaveProm/onboarding-integration-continue-waveprom, qu'il a cloné une fois la personne connectée.
Le seul contrat entre les deux dépôts : le système se clone dans `~/.waveprom/onboarding-integration-continue-waveprom` et y expose `bin/configurer.sh` ; changer l'un de ces deux noms exige la même modification dans l'autre dépôt, le même jour.

## Prérequis

Le Mac n'a que le Terminal et le zsh de macOS, plus trois choses faites avant l'installeur :

- l'app Claude desktop, installée et connectée ;
- un compte GitHub que la personne a créé elle-même, à la main, comme l'exigent les conditions d'utilisation de GitHub ;
- une invitation à WaveProm, envoyée par un owner de l'organisation à l'adresse e-mail de ce compte.

Ni Homebrew, ni git, ni Node ne sont nécessaires.
Sur un Mac qui porte `~/.hypnos`, celui d'un associé, déjà installé à la main, l'installeur refuse de tourner avant toute étape et ne touche à rien.

## Ce que fait l'installeur

Chaque étape lit son état avant d'agir et imprime une ligne.
Un run coupé, par le délai de 10 minutes de l'outil Bash de Claude Code ou par autre chose, reprend quand la même commande est relancée.
La personne fait deux gestes, parfois trois : le mot de passe du Mac, le clic sur « Authorize », et l'acceptation de l'invitation quand GitHub refuse de l'accepter par l'API.

1. Homebrew s'installe par son installeur officiel, sans question dans le terminal.
   Le mot de passe du Mac est demandé dans une fenêtre macOS, puisque l'outil Bash de Claude Code n'a pas de terminal où le taper.
   Homebrew installe les Command Line Tools d'Apple, et donc git.
   La ligne `brew shellenv` entre dans `~/.zprofile`, pour que zsh et Claude Code trouvent ce que Homebrew installe.
2. gh, la CLI de GitHub, s'installe dans sa version standard par `brew install gh`.
3. La connexion à GitHub passe par le navigateur.
   Le code est déjà copié, la page https://github.com/login/device s'ouvre, la personne colle le code et clique sur « Authorize ».
   Le seul scope demandé est `repo`, puis git passe par gh pour s'authentifier.
4. L'invitation à WaveProm est acceptée par l'API GitHub.
   Si GitHub refuse, la page https://github.com/orgs/WaveProm/invitation s'ouvre pour un clic, et l'installeur attend 5 minutes que l'adhésion soit active.
5. git signe les commits avec le nom et l'e-mail du compte GitHub.
   Quand l'e-mail du compte est privé, c'est l'adresse noreply de GitHub.
6. Chaque dépôt de WaveProm est cloné dans `~/.waveprom/<dépôt>`, le système compris.
   Un clone déjà présent reçoit `git fetch` et n'est jamais écrasé.
   Le dépôt privé du système ne se lit qu'à cette étape, une fois la personne connectée, puisqu'une URL raw privée ne répond pas sans connexion.
7. La vérification contrôle l'adhésion active, l'accès en écriture à chaque dépôt, la présence de chaque clone, et celle de `bin/configurer.sh` dans le clone du système.
   Le rôle n'est pas contrôlé : l'owner le choisit en envoyant l'invitation, admin pour un associé, membre pour un consultant.
8. `bin/configurer.sh` du système prend la main et pose tout ce qui suit les clones : les consignes de l'agence, et tout ce que Claude Code doit trouver à chaque session.
   Ses lignes commencent par « Configuration », et le README du système détaille ses étapes.
   Ensuite, le système se tient à jour seul au début de chaque session de Claude Code, sans repasser par l'installeur.

L'installeur finit sur « C'est prêt. », ou sur la ligne de l'étape qui a échoué.

Ce qu'impriment Homebrew, gh et git va dans `~/Library/Logs/WaveProm/installer.log`, et ce qu'imprime la configuration dans `configurer.log` à côté.

## Développement

`bin/installer.sh --dev` imprime en plus chaque contrôle des deux vérifications, celle de l'étape 7 et celle du système.
`bin/installer.sh --help` imprime l'en-tête du script.
Un run de développement, sur un Mac déjà installé, laisse son état dans un dossier temporaire :

```
H=$(mktemp -d)
HOME=$H GH_TOKEN=$(gh auth token) /bin/bash bin/installer.sh --dev
```

Tant qu'une pull request du système n'est pas fusionnée, son clone se pose d'abord sur sa branche dans `$H/.waveprom/onboarding-integration-continue-waveprom` : l'étape 6 le garde et lui donne `git fetch`.
Le script tourne sous le `/bin/bash` livré avec macOS, et `shellcheck bin/installer.sh` ne doit rien signaler.
La routine de maintenance, pour un agent, est dans [AGENTS.md](AGENTS.md).
