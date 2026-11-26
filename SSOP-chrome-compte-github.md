# SSOP - Chrome, le compte GitHub et ce que Claude dit à la personne

## Formes

| Donnée | Origine | Destination | Frontière | Forme | État illégal interdit |
| ------ | ------- | ----------- | --------- | ----- | --------------------- |
| Chrome installé | `/Applications/Google Chrome.app`, posé par la personne ou par Homebrew | `install_chrome` | `-d` sur le chemin de l'app | présent ou absent | `brew install --cask` lancé sur une app déjà posée à la main, qui échoue |
| Compte GitHub | la personne, qui le crée à la main sur la page d'inscription | `ask_for_github_account` | la session gh, sinon le témoin `~/.waveprom/compte-github-demande` | compte connu par gh, compte déjà demandé, ou compte à demander | la page d'inscription rouverte à chaque run, un compte créé par l'agent |
| Arrêt en attente de la personne | `ask_for_github_account` | Claude, par le code de sortie | le code 4, distinct de l'échec | une ligne sur stdout et le code 4 | une attente prise pour un échec, ou pour une installation prête |
| Page à ouvrir | l'inscription, le code d'appareil, l'invitation | Chrome | `open_in_chrome` | une URL ouverte dans Google Chrome | une page ouverte dans Safari ou dans le navigateur par défaut |
| Phrases pour la personne | l'en-tête de `bin/installer.sh` | Claude, puis la personne | les « » de l'en-tête | une phrase en français simple, dite telle quelle | une commande, un nom de fichier ou un terme git dits à la personne |
| Suite de l'installation | les dernières lignes de `bin/configurer.sh` du système | Claude | la ligne « Configuration : prête » | des consignes que Claude suit après « C'est prêt. » | l'installeur qui nomme ou recopie ce que le système fait ensuite |

## Ordre

| Produit | Besoins | Paramètres | Retour | Fichier |
| ------- | ------- | ---------- | ------ | ------- |
| la page ouverte dans Chrome | Chrome installé | une URL | la page au premier plan dans Chrome | bin/installer.sh, `open_in_chrome` |
| Chrome installé | Homebrew | - | l'app dans `/Applications` | bin/installer.sh, étape 2 |
| le compte GitHub demandé | la page ouverte dans Chrome, la session gh | - | 0 quand le compte est connu ou déjà demandé, 4 quand la page vient de s'ouvrir | bin/installer.sh, étape 3 |
| la connexion et l'invitation | la page ouverte dans Chrome, le compte GitHub demandé | - | session gh, adhésion active | bin/installer.sh, étapes 5 et 6 |
| ce que Claude dit à la personne | les dix étapes, leurs codes de sortie | - | les phrases entre « », dans l'ordre | bin/installer.sh, en-tête |
| la documentation | tout ce qui précède | - | les prérequis, les étapes, la routine | README.md, AGENTS.md |

Arêtes : Chrome installé vers la page ouverte dans Chrome ; la page ouverte vers le compte demandé, la connexion et l'invitation ; les étapes vers ce que Claude dit ; tout vers la documentation.
Donnée de frontière : les arguments, `/Applications`, la session gh, les fichiers de `$HOME`, les mots de la personne.

Tri :

1. Chrome installé
2. la page ouverte dans Chrome
3. le compte GitHub demandé ; la connexion et l'invitation
4. ce que Claude dit à la personne
5. la documentation

## Vérifications

| Module | Changement qu'il confine | Ce qu'un appelant doit savoir |
| ------ | ------------------------ | ----------------------------- |
| `open_in_chrome` | dans quel navigateur l'installeur ouvre une page | une URL en paramètre, statut non nul si Chrome ne l'ouvre pas |
| `install_chrome` | d'où vient Chrome et où il se lit | rien : il lit `/Applications` et n'installe que si l'app manque |
| `ask_for_github_account` | comment l'installeur obtient un compte que seul un humain peut créer | il renvoie 4 une seule fois, quand la page vient de s'ouvrir ; relancé, il continue |
| l'en-tête pour Claude | chaque phrase dite à la personne, et à quel moment | les phrases se disent telles quelles, dans l'ordre des codes de sortie |

## Propriété

| Fait | Propriétaire | Lecteurs | Écrivain |
| ---- | ------------ | -------- | -------- |
| Chrome installé | `/Applications/Google Chrome.app` | étape 2, `open_in_chrome` | la personne, sinon `brew install --cask google-chrome` |
| Le compte GitHub existe | GitHub | la personne, puis gh à l'étape 5 | la personne, à la main |
| La personne a été envoyée créer son compte | `~/.waveprom/compte-github-demande` | étape 3 | étape 3, une fois la page ouverte |
| Ce que Claude dit pendant l'installation | l'en-tête de `bin/installer.sh` | Claude | une pull request sur ce dépôt |
| Ce que Claude fait et dit après « C'est prêt. » | le système, par les dernières lignes de sa configuration | Claude | le système |

## Amendements
