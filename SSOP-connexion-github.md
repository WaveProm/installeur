# SSOP - la connexion au compte GitHub que la personne a déjà

## Formes

| Donnée | Origine | Destination | Frontière | Forme | État illégal interdit |
| ------ | ------- | ----------- | --------- | ----- | --------------------- |
| Compte GitHub | la personne, qui le crée seule dans Chrome avec le mail de l'agence, avant l'installation de Claude | gh, à l'étape 4 | la page https://github.com/login/device, qui demande de se connecter quand Chrome n'a pas de session | un compte qui existe, Chrome connecté ou non | une page d'inscription ouverte par l'installeur, un compte créé par un agent |
| Connexion annoncée à la personne | l'étape 4, sur un gh non connecté | Claude, par le code de sortie | le témoin `~/.waveprom/connexion-github-annoncee` | absent : l'installeur s'arrête une fois ; présent : il ouvre la page | la page de code ouverte avant que Claude ait dit à la personne ce qu'elle y verra, ou un arrêt à chaque run |
| Arrêt en attente de la personne | l'étape 4 | Claude | le code 4, distinct de l'échec | une ligne sur stdout et le code 4 | une attente prise pour un échec, ou pour une installation prête |
| Phrases pour la personne | l'en-tête de `bin/installer.sh` | Claude, puis la personne | les « » de l'en-tête | une phrase en français simple, dite telle quelle, dans l'ordre du parcours | une phrase qui parle d'inscription, une commande, un nom de fichier ou un terme git dits à la personne |

## Ordre

| Produit | Besoins | Paramètres | Retour | Fichier |
| ------- | ------- | ---------- | ------ | ------- |
| gh installé | Homebrew | - | gh sur le PATH | bin/installer.sh, `install_gh`, étape 3 |
| la connexion annoncée | gh installé, la session gh | - | 0 quand elle est déjà annoncée, 4 quand elle vient de l'être | bin/installer.sh, `announce_sign_in` |
| la connexion à GitHub | la connexion annoncée, la page ouverte dans Chrome | - | session gh avec `repo`, helper git, ou 4 | bin/installer.sh, `sign_in_to_github`, étape 4 |
| ce que Claude dit à la personne | les neuf étapes, leurs codes de sortie | - | les phrases entre « », dans l'ordre | bin/installer.sh, en-tête |
| la documentation | tout ce qui précède | - | les prérequis, les étapes, la routine | README.md, AGENTS.md |
| le journal | tout ce qui précède | - | une ligne par problème tranché | project-level-past-decisions-log.md |

Arêtes : gh installé vers la connexion annoncée ; la connexion annoncée vers la connexion à GitHub ; les étapes vers ce que Claude dit ; tout vers la documentation et le journal.
Donnée de frontière : la session gh, la session de GitHub dans Chrome, les fichiers de `$HOME`, `open_in_chrome`.

Tri :

1. gh installé
2. la connexion annoncée
3. la connexion à GitHub
4. ce que Claude dit à la personne
5. la documentation, le journal

## Vérifications

| Module | Changement qu'il confine | Ce qu'un appelant doit savoir |
| ------ | ------------------------ | ----------------------------- |
| `announce_sign_in` | le moment où Claude dit à la personne ce que Chrome va lui montrer | il renvoie 4 une seule fois, avant la première ouverture de la page ; relancé, il renvoie 0 |
| `sign_in_to_github` | les scopes, le flux du navigateur, et l'arrêt qui le précède | il renvoie 4 quand la connexion attend la personne, puis se relance tel quel |
| l'en-tête pour Claude | chaque phrase dite à la personne, et à quel moment | les phrases se disent telles quelles, dans l'ordre des codes de sortie |

## Propriété

| Fait | Propriétaire | Lecteurs | Écrivain |
| ---- | ------------ | -------- | -------- |
| Le compte GitHub existe | GitHub | la personne, puis gh à l'étape 4 | la personne, à la main, avec le mail de l'agence |
| Chrome est connecté au compte | Chrome, par la session de GitHub | la page de code | la personne, dans le mail, sinon sur la page de connexion que GitHub lui montre |
| La connexion a été annoncée à la personne | `~/.waveprom/connexion-github-annoncee` | étape 4 | étape 4, avant la première ouverture de la page |
| Ce que Claude dit pendant l'installation | l'en-tête de `bin/installer.sh` | Claude | une pull request sur ce dépôt |

## Amendements
