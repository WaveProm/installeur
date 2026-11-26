Claude Code : lis l'en-tête de [bin/installer.sh](bin/installer.sh), les lignes de commentaire sous le shebang, et suis-le.

# installeur

Prépare le Mac d'une personne qui rejoint WaveProm à agir sur chaque dépôt de l'organisation GitHub WaveProm.
La personne ouvre l'onglet Code de l'app Claude sur son dossier personnel et écrit « Installe github.com/WaveProm/installeur ».
Claude Code lance alors `bin/installer.sh`, et guide seul la personne, phrase par phrase : l'installation, la connexion de ce Mac au compte GitHub qu'elle a déjà créé, puis ce que le système de l'agence lui fait faire ensuite.

Ce dépôt est public, puisque Claude Code le lit avant que la personne soit connectée à GitHub.
L'installeur s'arrête aux clones, puis passe la main au système de l'agence, le dépôt privé WaveProm/onboarding-integration-continue-waveprom, qu'il a cloné une fois la personne connectée.
Le seul contrat entre les deux dépôts : le système se clone dans `~/.waveprom/onboarding-integration-continue-waveprom` et y expose `bin/configurer.sh` ; changer l'un de ces deux noms exige la même modification dans l'autre dépôt, le même jour.

## Prérequis

Le Mac n'a que le Terminal et le zsh de macOS, plus ce que le mail de l'agence fait faire à la personne avant l'installeur, dans cet ordre :

- Google Chrome, installé par la personne, et devenu son navigateur par défaut : l'agence travaille dans Chrome et dans aucun autre navigateur ;
- son compte GitHub, créé dans Chrome avec l'adresse e-mail où elle a reçu le mail, ou le compte qu'elle a déjà à cette adresse, auquel elle se connecte dans Chrome ;
- ce compte confirmé avec le code que GitHub envoie par e-mail ;
- l'app Claude desktop, installée et connectée, son onglet Code ouvert sur « Cet ordinateur » et sur le dossier personnel ;
- le mode « Ignorer les permissions » de l'onglet Code, activé avant de coller la phrase, pour qu'aucune demande d'autorisation ne s'affiche.

Il faut aussi une invitation à WaveProm, envoyée par un owner de l'organisation à l'adresse e-mail du compte GitHub de la personne.
Le compte GitHub se crée avant l'installeur, par la personne seule, comme l'exigent les conditions d'utilisation de GitHub : l'installeur ne fait créer aucun compte, il relie ce Mac à celui qui existe.
Ni Homebrew, ni git, ni Node ne sont nécessaires.
Sur un Mac qui porte `~/.hypnos`, celui d'un associé, déjà installé à la main, l'installeur refuse de tourner avant toute étape et ne touche à rien.

## Ce que fait l'installeur

Chaque étape lit son état avant d'agir et imprime une ligne.
Un run coupé, par le délai de 10 minutes de l'outil Bash de Claude Code ou par autre chose, reprend quand la même commande est relancée.
La personne fait deux gestes : le mot de passe du Mac, puis le code collé suivi des clics sur « Continue » et « Authorize ».
S'y ajoutent la connexion à son compte, quand GitHub la demande parce que Chrome n'y est pas connecté, et l'acceptation de l'invitation, quand GitHub refuse de l'accepter par l'API.
Chaque page que l'installeur ouvre s'ouvre dans Chrome, par `open -a "Google Chrome"`.

1. Homebrew s'installe par son installeur officiel, sans question dans le terminal.
   Le mot de passe du Mac est demandé dans une fenêtre macOS, puisque l'outil Bash de Claude Code n'a pas de terminal où le taper.
   Homebrew installe les Command Line Tools d'Apple, et donc git.
   La ligne `brew shellenv` entre dans `~/.zprofile`, pour que zsh et Claude Code trouvent ce que Homebrew installe.
2. Google Chrome est contrôlé : l'étape est faite quand `/Applications/Google Chrome.app` existe, posé par la personne ou par Homebrew.
   Quand l'app manque, elle s'installe par `brew install --cask google-chrome`, qui échouerait sur une app déjà posée à la main.
3. gh, la CLI de GitHub, s'installe dans sa version standard par `brew install gh`.
4. La connexion au compte GitHub de la personne passe par Chrome.
   Quand gh n'est pas encore connecté, l'installeur s'arrête une fois avant d'ouvrir la moindre page, sur une ligne et le code de sortie 4.
   Claude dit alors à la personne ce que Chrome va lui montrer, puis relance l'installeur sans attendre de réponse.
   Le témoin `~/.waveprom/connexion-github-annoncee` garde le moment de cet arrêt : relancé, l'installeur continue.
   Le code est déjà copié, la page https://github.com/login/device s'ouvre, la personne colle le code, clique sur « Continue » puis sur « Authorize ».
   Quand Chrome n'est pas connecté au compte, GitHub montre d'abord sa page de connexion, où la personne entre son adresse e-mail et son mot de passe.
   Le seul scope demandé est `repo`, puis git passe par gh pour s'authentifier.
5. L'invitation à WaveProm est acceptée par l'API GitHub.
   Si GitHub refuse, la page https://github.com/orgs/WaveProm/invitation s'ouvre dans Chrome pour un clic, et l'installeur attend 5 minutes que l'adhésion soit active.
6. git signe les commits avec le nom et l'e-mail du compte GitHub.
   Quand l'e-mail du compte est privé, c'est l'adresse noreply de GitHub.
7. Chaque dépôt de WaveProm est cloné dans `~/.waveprom/<dépôt>`, le système compris.
   Un clone déjà présent reçoit `git fetch` et n'est jamais écrasé.
   Le dépôt privé du système ne se lit qu'à cette étape, une fois la personne connectée, puisqu'une URL raw privée ne répond pas sans connexion.
8. La vérification contrôle l'adhésion active, l'accès en écriture à chaque dépôt, la présence de chaque clone, et celle de `bin/configurer.sh` dans le clone du système.
   Le rôle n'est pas contrôlé : l'owner le choisit en envoyant l'invitation, admin pour un associé, membre pour un consultant.
9. `bin/configurer.sh` du système prend la main et pose tout ce qui suit les clones : les consignes de l'agence, et tout ce que Claude Code doit trouver à chaque session.
   Ses lignes commencent par « Configuration », et le README du système détaille ses étapes.
   Ce qu'il imprime en dernier dit à Claude quoi faire ensuite avec la personne, et l'en-tête de l'installeur dit à Claude de le suivre.
   Ensuite, le système se tient à jour seul au début de chaque session de Claude Code, sans repasser par l'installeur.

L'installeur finit sur « C'est prêt. », sur la ligne de l'étape 4 quand la connexion à GitHub attend la personne, ou sur la ligne de l'étape qui a échoué.

## Ce que Claude dit à la personne

Chaque phrase que Claude dit pendant l'installation est écrite entre « » dans l'en-tête de `bin/installer.sh`, à côté du moment où elle se dit : avant de lancer, à l'arrêt avant la connexion à GitHub, à la relance, à la fin.
Ce sont des phrases en français simple sur ce que la personne voit et fait, au tutoiement comme le mail de l'agence, sans commande, nom de fichier ni terme git.
Après « C'est prêt. », les phrases sont celles du système de l'agence.

Ce qu'impriment Homebrew, gh et git va dans `~/Library/Logs/WaveProm/installer.log`, et ce qu'imprime la configuration dans `configurer.log` à côté.

## Développement

`bin/installer.sh --dev` imprime en plus chaque contrôle des deux vérifications, celle de l'étape 8 et celle du système.
`bin/installer.sh --help` imprime l'en-tête du script.
Un run de développement, sur un Mac déjà installé, laisse son état dans un dossier temporaire :

```
H=$(mktemp -d)
HOME=$H GH_TOKEN=$(gh auth token) /bin/bash bin/installer.sh --dev
```

Avec `GH_TOKEN`, gh est déjà connecté : l'étape 4 passe sans s'arrêter, et aucune page ne s'ouvre dans Chrome.
Tant qu'une pull request du système n'est pas fusionnée, son clone se pose d'abord sur sa branche dans `$H/.waveprom/onboarding-integration-continue-waveprom` : l'étape 7 le garde et lui donne `git fetch`.
Le script tourne sous le `/bin/bash` livré avec macOS, et `shellcheck bin/installer.sh` ne doit rien signaler.
La routine de maintenance, pour un agent, est dans [AGENTS.md](AGENTS.md).
