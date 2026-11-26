Claude Code : lis l'en-tête de [bin/installer.sh](bin/installer.sh), les lignes de commentaire sous le shebang, et suis-le.

# installeur

Prépare le Mac d'une personne qui rejoint WaveProm à agir sur chaque dépôt de l'organisation GitHub WaveProm.
La personne ouvre l'onglet Code de l'app Claude sur son dossier personnel et écrit « Installe github.com/WaveProm/installeur ».
Claude Code lance alors `bin/installer.sh`, et guide seul la personne, phrase par phrase : Chrome, son compte GitHub, l'installation, puis ce que le système de l'agence lui fait faire ensuite.

Ce dépôt est public, puisque Claude Code le lit avant que la personne soit connectée à GitHub.
L'installeur s'arrête aux clones, puis passe la main au système de l'agence, le dépôt privé WaveProm/onboarding-integration-continue-waveprom, qu'il a cloné une fois la personne connectée.
Le seul contrat entre les deux dépôts : le système se clone dans `~/.waveprom/onboarding-integration-continue-waveprom` et y expose `bin/configurer.sh` ; changer l'un de ces deux noms exige la même modification dans l'autre dépôt, le même jour.

## Prérequis

Le Mac n'a que le Terminal et le zsh de macOS, plus quatre choses faites avant l'installeur, dans cet ordre, que le mail de l'agence fait faire à la personne :

- Google Chrome, installé et ouvert par la personne, et devenu son navigateur par défaut : l'agence travaille dans Chrome et dans aucun autre navigateur ;
- l'app Claude desktop, installée et connectée ;
- le mode « Ignorer les permissions » de l'onglet Code, activé dans les paramètres de l'app puis choisi sous la zone de saisie avant de coller la phrase, pour qu'aucune demande d'autorisation ne s'affiche ;
- une invitation à WaveProm, envoyée par un owner de l'organisation à l'adresse e-mail professionnelle de la personne.

Le compte GitHub se crée pendant l'installation : l'installeur ouvre la page d'inscription, et la personne le crée elle-même, à la main, comme l'exigent les conditions d'utilisation de GitHub.
Ni Homebrew, ni git, ni Node ne sont nécessaires.
Sur un Mac qui porte `~/.hypnos`, celui d'un associé, déjà installé à la main, l'installeur refuse de tourner avant toute étape et ne touche à rien.

## Ce que fait l'installeur

Chaque étape lit son état avant d'agir et imprime une ligne.
Un run coupé, par le délai de 10 minutes de l'outil Bash de Claude Code ou par autre chose, reprend quand la même commande est relancée.
La personne fait trois gestes, parfois quatre : le mot de passe du Mac, la création de son compte GitHub, le code collé suivi du clic sur « Authorize », et l'acceptation de l'invitation quand GitHub refuse de l'accepter par l'API.
Chaque page que l'installeur ouvre s'ouvre dans Chrome, par `open -a "Google Chrome"`.

1. Homebrew s'installe par son installeur officiel, sans question dans le terminal.
   Le mot de passe du Mac est demandé dans une fenêtre macOS, puisque l'outil Bash de Claude Code n'a pas de terminal où le taper.
   Homebrew installe les Command Line Tools d'Apple, et donc git.
   La ligne `brew shellenv` entre dans `~/.zprofile`, pour que zsh et Claude Code trouvent ce que Homebrew installe.
2. Google Chrome est contrôlé : l'étape est faite quand `/Applications/Google Chrome.app` existe, posé par la personne ou par Homebrew.
   Quand l'app manque, elle s'installe par `brew install --cask google-chrome`, qui échouerait sur une app déjà posée à la main.
3. Le compte GitHub est demandé à la personne.
   Quand gh n'est pas encore connecté, la page https://github.com/signup s'ouvre dans Chrome, et l'installeur s'arrête là, sur une ligne et le code de sortie 4.
   Claude dit à la personne de créer son compte elle-même, avec l'adresse professionnelle que l'agence a invitée, et de répondre « fait », puis relance l'installeur.
   Le témoin `~/.waveprom/compte-github-demande` garde le moment de cette demande : relancé, l'installeur continue au lieu de rouvrir la page.
4. gh, la CLI de GitHub, s'installe dans sa version standard par `brew install gh`.
5. La connexion à GitHub passe par Chrome.
   Le code est déjà copié, la page https://github.com/login/device s'ouvre, la personne colle le code et clique sur « Authorize ».
   Le seul scope demandé est `repo`, puis git passe par gh pour s'authentifier.
6. L'invitation à WaveProm est acceptée par l'API GitHub.
   Si GitHub refuse, la page https://github.com/orgs/WaveProm/invitation s'ouvre dans Chrome pour un clic, et l'installeur attend 5 minutes que l'adhésion soit active.
7. git signe les commits avec le nom et l'e-mail du compte GitHub.
   Quand l'e-mail du compte est privé, c'est l'adresse noreply de GitHub.
8. Chaque dépôt de WaveProm est cloné dans `~/.waveprom/<dépôt>`, le système compris.
   Un clone déjà présent reçoit `git fetch` et n'est jamais écrasé.
   Le dépôt privé du système ne se lit qu'à cette étape, une fois la personne connectée, puisqu'une URL raw privée ne répond pas sans connexion.
9. La vérification contrôle l'adhésion active, l'accès en écriture à chaque dépôt, la présence de chaque clone, et celle de `bin/configurer.sh` dans le clone du système.
   Le rôle n'est pas contrôlé : l'owner le choisit en envoyant l'invitation, admin pour un associé, membre pour un consultant.
10. `bin/configurer.sh` du système prend la main et pose tout ce qui suit les clones : les consignes de l'agence, et tout ce que Claude Code doit trouver à chaque session.
    Ses lignes commencent par « Configuration », et le README du système détaille ses étapes.
    Ce qu'il imprime en dernier dit à Claude quoi faire ensuite avec la personne, et l'en-tête de l'installeur dit à Claude de le suivre.
    Ensuite, le système se tient à jour seul au début de chaque session de Claude Code, sans repasser par l'installeur.

L'installeur finit sur « C'est prêt. », sur la ligne de l'étape 3 quand il attend le compte GitHub, ou sur la ligne de l'étape qui a échoué.

## Ce que Claude dit à la personne

Chaque phrase que Claude dit pendant l'installation est écrite entre « » dans l'en-tête de `bin/installer.sh`, à côté du moment où elle se dit : avant de lancer, à l'arrêt sur le compte GitHub, à la relance, à la fin.
Ce sont des phrases en français simple sur ce que la personne voit et fait, sans commande, nom de fichier ni terme git.
Après « C'est prêt. », les phrases sont celles du système de l'agence.

Ce qu'impriment Homebrew, gh et git va dans `~/Library/Logs/WaveProm/installer.log`, et ce qu'imprime la configuration dans `configurer.log` à côté.

## Développement

`bin/installer.sh --dev` imprime en plus chaque contrôle des deux vérifications, celle de l'étape 9 et celle du système.
`bin/installer.sh --help` imprime l'en-tête du script.
Un run de développement, sur un Mac déjà installé, laisse son état dans un dossier temporaire :

```
H=$(mktemp -d)
HOME=$H GH_TOKEN=$(gh auth token) /bin/bash bin/installer.sh --dev
```

Avec `GH_TOKEN`, gh est déjà connecté : l'étape 3 passe sans ouvrir la page d'inscription, et aucune page ne s'ouvre dans Chrome.
Tant qu'une pull request du système n'est pas fusionnée, son clone se pose d'abord sur sa branche dans `$H/.waveprom/onboarding-integration-continue-waveprom` : l'étape 8 le garde et lui donne `git fetch`.
Le script tourne sous le `/bin/bash` livré avec macOS, et `shellcheck bin/installer.sh` ne doit rien signaler.
La routine de maintenance, pour un agent, est dans [AGENTS.md](AGENTS.md).
