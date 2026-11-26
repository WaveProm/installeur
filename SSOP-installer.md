# SSOP - installer.sh

## Formes

| Donnée | Origine | Destination | Frontière | Forme | État illégal interdit |
| ------ | ------- | ----------- | --------- | ----- | --------------------- |
| Arguments | ligne de commande | `main` | le `case` de `main` | `mode` vaut `dev` ou `production` | une option inconnue ignorée en silence |
| Script de Homebrew | `raw.githubusercontent.com/Homebrew/install/HEAD/install.sh` | `/bin/bash -c` | le statut de `curl -fsSL` et le texte non vide | texte du script | un téléchargement raté exécuté comme un script vide qui réussit |
| Mot de passe macOS | dialogue `osascript` | `sudo -A` | le script `SUDO_ASKPASS` | texte sur stdout, jamais écrit sur disque | un mot de passe stocké dans un fichier |
| Ligne PATH de zsh | `${ZDOTDIR:-$HOME}/.zprofile` | `install_homebrew` | `grep` du motif de Homebrew | présente ou absente | une deuxième ligne `brew shellenv` ajoutée à chaque run |
| Session GitHub | `gh auth status --json hosts` | `sign_in_to_github` | le `--jq` qui ne garde que le compte actif, en succès, avec le scope `repo` | un login, ou rien | une session sans `repo` prise pour une session valide |
| Helper git | `git config --global --get-all credential.https://github.com.helper` | `sign_in_to_github` | `grep 'gh auth git-credential'` | présent ou absent | git qui demande un mot de passe au clone |
| Adhésion | `GET /user/memberships/orgs/WaveProm` | `accept_invitation`, `check_ready` | le `--jq` sur `.state` et `.role` | `state` vaut `active`, `pending`, ou rien sur un 404 | un état autre que `active` pris pour une adhésion |
| Compte GitHub | `GET /user` | `set_git_identity` | le `--jq` qui calcule les trois lignes | login, nom jamais vide, e-mail public ou noreply | un `user.email` vide, ou l'adresse privée publiée dans un commit |
| Dépôts de l'organisation | `GET /orgs/WaveProm/repos`, paginé | `clone_repositories`, `check_ready` | `org_repositories` | une ligne `nom push` par dépôt | deux listes des dépôts qui divergent entre l'étape 6 et l'étape 8 |
| Réglages Claude Code | `~/.claude/settings.json` | `allow_claude_commands` | `jq`, qui refuse un JSON invalide | objet JSON, clés existantes gardées | un fichier écrasé, ou une règle ajoutée deux fois |

## Ordre

| Produit | Besoins | Paramètres | Retour | Fichier |
| ------- | ------- | ---------- | ------ | ------- |
| `say`, `fail` | - | une ligne | 0, ou 1 pour `fail` | installer.sh |
| `ask_password_script` | - | - | le chemin d'un script `SUDO_ASKPASS` | installer.sh |
| `org_repositories` | gh connecté | - | `nom push` par ligne | installer.sh |
| `membership` | gh connecté | - | `state role`, ou rien | installer.sh |
| `install_homebrew` | `ask_password_script`, `say`, `fail` | - | brew sur le PATH du script et de zsh | installer.sh |
| `install_gh` | `install_homebrew` | - | gh sur le PATH | installer.sh |
| `sign_in_to_github` | `install_gh` | - | session gh avec `repo`, helper git | installer.sh |
| `accept_invitation` | `sign_in_to_github`, `membership` | - | adhésion `active` | installer.sh |
| `set_git_identity` | `sign_in_to_github` | - | `user.name`, `user.email` | installer.sh |
| `clone_repositories` | `sign_in_to_github`, `org_repositories` | - | un clone par dépôt dans `~/.waveprom` | installer.sh |
| `allow_claude_commands` | `install_homebrew` | - | trois règles dans `permissions.allow` | installer.sh |
| `check_ready` | `membership`, `org_repositories` | `mode` | `C'est prêt.` ou la ligne de l'échec | installer.sh |
| `main` | toutes les étapes | `--dev` ou rien | code de sortie | installer.sh |

Arêtes : `membership` et `org_repositories` vers `accept_invitation`, `clone_repositories`, `check_ready` ; `ask_password_script` vers `install_homebrew` ; chaque étape vers `main`.
Donnée de frontière : arguments, API GitHub, `install.sh` de Homebrew, fichiers de `$HOME`.

Tri :

1. `say`, `fail`, `ask_password_script`, `org_repositories`, `membership`
2. `install_homebrew`, `install_gh`, `sign_in_to_github`, `accept_invitation`, `set_git_identity`, `clone_repositories`, `allow_claude_commands`, `check_ready`
3. `main`

## Vérifications

| Module | Changement qu'il confine | Ce qu'un appelant doit savoir |
| ------ | ------------------------ | ----------------------------- |
| `say`, `fail` | la forme d'une ligne pour la personne, stdout ou stderr | une ligne en français, `fail` renvoie 1 |
| `ask_password_script` | comment macOS demande le mot de passe | le chemin rendu est à supprimer après usage |
| `org_repositories` | quels dépôts comptent pour l'organisation | une ligne `nom push`, statut non nul si l'API refuse |
| `membership` | comment l'adhésion se lit | `state role`, vide si aucune adhésion |
| `install_homebrew` | où vit Homebrew et comment il arrive sur le PATH | rien : il lit et écrit son propre état |
| `install_gh` | quelle version de gh est installée | rien |
| `sign_in_to_github` | les scopes demandés et le flux du navigateur | rien |
| `accept_invitation` | comment une invitation est acceptée | rien |
| `set_git_identity` | quelle identité signe les commits | rien |
| `clone_repositories` | où vivent les clones, `REPOSITORIES_NAME` | un clone existant est récupéré, jamais écrasé |
| `allow_claude_commands` | quelles commandes Claude Code lance sans demander | les clés existantes restent |
| `check_ready` | ce que veut dire « prêt » | `mode` décide du détail affiché |

## Propriété

| Fait | Propriétaire | Lecteurs | Écrivain |
| ---- | ------------ | -------- | -------- |
| Homebrew installé | `/opt/homebrew/bin/brew` | étapes 1, 2, 7 | `install.sh` de Homebrew |
| Ligne PATH de zsh | `~/.zprofile` | étape 1 | étape 1 |
| gh installé | Homebrew | étape 2 | `brew install gh` |
| Session GitHub | gh, trousseau macOS ou `GH_TOKEN` | étapes 3 à 8 | `gh auth login` |
| Helper git | `~/.gitconfig` | git | `gh auth setup-git` |
| Adhésion à WaveProm | GitHub | étapes 4 et 8 | `PATCH`, ou le clic de la personne |
| Identité git | `~/.gitconfig` | git | étape 5 |
| Liste des dépôts | GitHub | étapes 6 et 8, par `org_repositories` | un owner de WaveProm |
| Clones | `~/.waveprom/<dépôt>` | étapes 6 et 8 | étape 6 |
| Règles Claude Code | `~/.claude/settings.json` | Claude Code, étape 7 | étape 7 |
| Mode | l'argument de `main` | `check_ready` | la ligne de commande |

## Amendements
- `install_homebrew` délègue le téléchargement et le run de l'installeur officiel à `run_homebrew_installer`, qui supprime le script `SUDO_ASKPASS` dès la fin.
- `ask_password_script` écrit le dialogue par un here document, sur le modèle de `~/.hypnos/bin/hy-askpass.sh` : `activate`, réponse cachée, abandon après 120 secondes.
- `sign_in_to_github` délègue le flux du navigateur à `log_in_with_browser`, qui ouvre https://github.com/login/device dès que gh a imprimé l'URL, puisque gh sans terminal ne l'ouvre pas.
- `signed_in_login` rend le login seulement quand la session porte le scope `repo` ; `git_uses_gh` lit le helper git.
- `accept_invitation` attend l'adhésion active par `wait_for_active_membership`, 5 minutes, car le PATCH peut répondre 202, traité en asynchrone.
- `clone_repository` clone dans `~/.waveprom.partial` puis déplace, et `clone_repositories` refuse un dossier existant qui n'est pas un clone.
- `run_logged`, `details`, `shown` et `counted` tiennent la forme des lignes : sortie des outils dans le journal, chemin affiché sous `~`, accord du pluriel.
- `print_head` et `installer_text` impriment l'en-tête pour `--help`, depuis le fichier, ou depuis l'URL raw quand le script arrive par un pipe.
- Le dépôt devient `WaveProm/onboarding-integration-continue-waveprom`, et les instructions pour Claude Code passent du README à l'en-tête du script.
- `check_ready` n'exige plus le rôle admin : l'adhésion active et l'écriture sur chaque dépôt suffisent, le rôle reste affiché en `--dev`.
- `record_versions` ajoute l'étape 9 : `tool_version` lit la version par la commande de l'outil, `tool_origin` et `formula_name` sa source et son package, `version_entry` l'entrée JSON.
- « C'est prêt. » passe de `check_ready` à `main`, après l'étape 9 ; sans `--dev`, `check_ready` n'imprime rien quand tout tient.
- Le dépôt est renommé `WaveProm/onboarding-integration-continue-waveprom` ; sur décision de Hypnos, chaque mention de l'ancien nom est remplacée, cette preuve comprise.
