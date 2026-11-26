#!/bin/bash
# installer.sh - prépare le Mac d'une personne qui rejoint WaveProm à agir sur chaque dépôt de l'organisation.
#
# Pour Claude Code, à lire avant de lancer le script :
#   La seule commande à lancer, avec le délai maximal de l'outil Bash, 600000 ms :
#     curl -fsSL https://raw.githubusercontent.com/WaveProm/installeur/main/bin/installer.sh | /bin/bash
#   Coupée, par ce délai ou autre chose, elle se relance telle quelle : chaque étape lit son état et reprend.
#   Avant de la lancer, dire à la personne, en une ligne chacun :
#     une fenêtre macOS va demander le mot de passe de ce Mac ;
#     la page GitHub ouverte dans le navigateur attend qu'elle colle le code déjà copié, puis clique « Authorize » ;
#     si une page d'invitation de WaveProm s'ouvre, elle attend qu'elle accepte l'invitation.
#   À la fin, ne lui montrer que « C'est prêt. », ou la ligne de l'étape qui a échoué.
#
# Usage :
#   installer.sh          les huit étapes, puis « C'est prêt. » ou la ligne de l'étape qui a échoué
#   installer.sh --dev    les huit étapes, et chaque contrôle des vérifications, celle de l'étape 7 et celle du système
#   installer.sh --help   imprime cet en-tête, lu depuis l'URL raw quand le script arrive par un pipe
#   Sur un Mac qui porte ~/.hypnos, celui d'un associé, déjà installé à la main, il refuse avant toute étape.
#
# Le contrat avec le système : le dépôt privé WaveProm/onboarding-integration-continue-waveprom se clone dans
# ~/.waveprom/onboarding-integration-continue-waveprom et y expose bin/configurer.sh, que l'étape 8 lance ;
# changer l'un de ces deux noms exige la même modification dans l'autre dépôt, le même jour.
#
# Étapes, chacune lit son état avant d'agir et imprime une ligne :
#   1. Homebrew, par son installeur officiel, NONINTERACTIVE=1 et SUDO_ASKPASS sur un dialogue macOS ;
#      il installe les Command Line Tools, donc git, et la ligne brew shellenv entre dans ~/.zprofile.
#   2. gh, par brew install gh.
#   3. La connexion à GitHub, gh auth login --web --clipboard avec le scope repo, puis gh auth setup-git.
#   4. L'invitation à WaveProm, acceptée par PATCH /user/memberships/orgs/WaveProm, sinon par un clic
#      sur https://github.com/orgs/WaveProm/invitation, attendu 5 minutes.
#   5. user.name et user.email de git, pris du compte GitHub, l'adresse noreply quand l'e-mail est privé.
#   6. ~/.waveprom/<dépôt>, un clone par dépôt de WaveProm, le système compris ; un clone existant reçoit
#      git fetch, jamais écrasé. Le dépôt privé du système ne se lit qu'ici, une fois la personne connectée.
#   7. La vérification : adhésion active, quel que soit le rôle, écriture sur chaque dépôt, chaque clone présent,
#      bin/configurer.sh présent dans le clone du système ; sans --dev, elle n'imprime rien quand tout tient.
#   8. bin/configurer.sh du système prend la main, avec --dev en mode dev, et pose le reste : outils, autorisations
#      de Claude Code, consignes de l'agence, hook de début de session, vérification du système, versions.
#      Ses lignes commencent par « Configuration », et sa ligne d'échec dit l'étape qui a échoué.
#
# Sortie : une ligne par étape sur stdout, la ligne d'un échec sur stderr, et ce qu'impriment les outils
#          dans ~/Library/Logs/WaveProm/installer.log, ceux de la configuration dans configurer.log à côté.
# Codes de sortie : 0 prêt ; 1 une étape a échoué, configuration comprise ; 2 option inconnue ;
#                   3 Mac d'un associé, rien n'est touché.
set -u -o pipefail

INSTALLER_URL="https://raw.githubusercontent.com/WaveProm/installeur/main/bin/installer.sh"
ORG="WaveProm"
HOST="github.com"
REPOSITORIES_NAME=".waveprom"
REPOSITORIES_DIR="$HOME/$REPOSITORIES_NAME"
SYSTEM_CLONE="$REPOSITORIES_DIR/onboarding-integration-continue-waveprom"
CONFIGURER="$SYSTEM_CLONE/bin/configurer.sh"
BREW="/opt/homebrew/bin/brew"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
DEVICE_URL="https://github.com/login/device"
INVITATION_URL="https://github.com/orgs/$ORG/invitation"
GITHUB_SCOPE="repo"
LOG_FILE="$HOME/Library/Logs/WaveProm/installer.log"
INVITATION_WAIT_SECONDS=300
ASSOCIATE_DIR="$HOME/.hypnos"

installer_text() {
  if [[ -f ${BASH_SOURCE[0]:-} ]]; then
    cat "${BASH_SOURCE[0]}"
  else
    curl -fsSL "$INSTALLER_URL"
  fi
}

print_head() {
  installer_text | awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }'
}

say() {
  printf '%s\n' "$1"
}

fail() {
  printf '%s\n' "$1" >&2
  return 1
}

shown() {
  printf '%s' "${1/#$HOME/~}"
}

run_logged() {
  "$@" </dev/null >>"$LOG_FILE" 2>&1
}

details() {
  printf 'détails dans %s' "$(shown "$LOG_FILE")"
}

counted() {
  if (($1 > 1)); then
    printf '%s %ss' "$1" "$2"
  else
    printf '%s %s' "$1" "$2"
  fi
}

ask_password_script() {
  local script
  script=$(mktemp -t waveprom-askpass) || return 1
  cat >"$script" <<'ASKPASS' || return 1
#!/bin/bash
exec /usr/bin/osascript \
  -e 'on run argv' \
  -e 'activate' \
  -e 'set reply to display dialog (item 1 of argv) default answer "" with title "Installation WaveProm" with icon caution with hidden answer giving up after 120' \
  -e 'if gave up of reply then error number -128' \
  -e 'return text returned of reply' \
  -e 'end run' \
  "Homebrew a besoin du mot de passe de ce Mac pour s’installer." 2>/dev/null
ASKPASS
  chmod 700 "$script" && printf '%s\n' "$script"
}

run_homebrew_installer() {
  local installer askpass status
  if ! installer=$(curl -fsSL "$HOMEBREW_INSTALLER_URL" 2>>"$LOG_FILE") || [[ -z $installer ]]; then
    fail "1/8 Homebrew : téléchargement de l'installeur officiel impossible, $(details)."
    return 1
  fi
  askpass=$(ask_password_script) ||
    { fail "1/8 Homebrew : création du dialogue de mot de passe impossible."; return 1; }
  NONINTERACTIVE=1 SUDO_ASKPASS="$askpass" /bin/bash -c "$installer" </dev/null >>"$LOG_FILE" 2>&1
  status=$?
  rm -f "$askpass"
  [[ $status -eq 0 && -x $BREW ]] ||
    fail "1/8 Homebrew : échec de l'installation, $(details)."
}

install_homebrew() {
  local zprofile="${ZDOTDIR:-$HOME}/.zprofile"
  local installed="déjà installé"
  if [[ ! -x $BREW ]]; then
    say "1/8 Homebrew : installation, une fenêtre macOS va demander le mot de passe de ce Mac."
    run_homebrew_installer || return 1
    installed="installé"
  fi
  eval "$("$BREW" shellenv bash)"
  if grep -qs "eval \"\$($BREW shellenv[^\"]*)\"" "$zprofile"; then
    say "1/8 Homebrew : $installed, déjà sur le PATH de zsh."
    return 0
  fi
  printf '\n%s\n' "eval \"\$($BREW shellenv zsh)\"" >>"$zprofile" ||
    { fail "1/8 Homebrew : $installed, mais $(shown "$zprofile") refuse l'écriture."; return 1; }
  say "1/8 Homebrew : $installed, ajouté au PATH de zsh dans $(shown "$zprofile")."
}

install_gh() {
  if command -v gh >/dev/null; then
    say "2/8 gh : déjà installé."
    return 0
  fi
  if ! run_logged "$BREW" install gh || ! command -v gh >/dev/null; then
    fail "2/8 gh : échec de brew install gh, $(details)."
    return 1
  fi
  say "2/8 gh : installé par Homebrew."
}

signed_in_login() {
  local login scopes
  read -r login scopes <<<"$(gh auth status --hostname "$HOST" --json hosts \
    --jq '.hosts[][]? | select(.active and .state == "success") | "\(.login) \(.scopes // "")"' 2>>"$LOG_FILE")"
  [[ -n $login && ", $scopes," == *", $GITHUB_SCOPE,"* ]] && printf '%s\n' "$login"
}

log_in_with_browser() {
  local output pid status tries=0
  output=$(mktemp -t waveprom-login) || return 1
  gh auth login --web --clipboard --hostname "$HOST" --git-protocol https --scopes "$GITHUB_SCOPE" \
    </dev/null >"$output" 2>&1 &
  pid=$!
  until grep -q "$DEVICE_URL" "$output" || ! kill -0 "$pid" 2>/dev/null || ((tries >= 60)); do
    sleep 0.5
    tries=$((tries + 1))
  done
  open "$DEVICE_URL"
  wait "$pid"
  status=$?
  cat "$output" >>"$LOG_FILE"
  rm -f "$output"
  return "$status"
}

git_uses_gh() {
  git config --global --get-all "credential.https://$HOST.helper" 2>/dev/null | grep -q 'gh auth git-credential'
}

sign_in_to_github() {
  local login signed="déjà connecté"
  login=$(signed_in_login)
  if [[ -z $login ]]; then
    say "3/8 GitHub : collez le code déjà copié sur la page ouverte dans le navigateur, puis cliquez sur « Authorize »."
    log_in_with_browser
    login=$(signed_in_login)
    [[ -n $login ]] || { fail "3/8 GitHub : connexion non aboutie, $(details)."; return 1; }
    signed="connecté"
  fi
  if git_uses_gh; then
    say "3/8 GitHub : $signed en tant que $login, git déjà relié à gh."
    return 0
  fi
  run_logged gh auth setup-git --hostname "$HOST" ||
    { fail "3/8 GitHub : $signed en tant que $login, mais gh auth setup-git a échoué, $(details)."; return 1; }
  say "3/8 GitHub : $signed en tant que $login, git relié à gh."
}

membership() {
  gh api "user/memberships/orgs/$ORG" --jq '"\(.state) \(.role)"' 2>>"$LOG_FILE"
}

wait_for_active_membership() {
  local deadline=$((SECONDS + INVITATION_WAIT_SECONDS))
  until [[ $(membership) == active* ]]; do
    ((SECONDS < deadline)) || return 1
    sleep 5
  done
}

accept_invitation() {
  local state role accepted_by="par l'API"
  read -r state role <<<"$(membership)"
  if [[ $state == active ]]; then
    say "4/8 $ORG : déjà membre actif, rôle $role."
    return 0
  fi
  if ! run_logged gh api --method PATCH "user/memberships/orgs/$ORG" -f state=active; then
    say "4/8 $ORG : acceptez l'invitation sur la page ouverte dans le navigateur."
    open "$INVITATION_URL"
    accepted_by="sur la page GitHub"
  fi
  wait_for_active_membership ||
    { fail "4/8 $ORG : toujours pas membre actif après $((INVITATION_WAIT_SECONDS / 60)) minutes. Vérifiez qu'un owner de $ORG a invité l'adresse e-mail de ce compte GitHub, puis relancez l'installeur."; return 1; }
  read -r state role <<<"$(membership)"
  say "4/8 $ORG : invitation acceptée $accepted_by, membre actif, rôle $role."
}

set_git_identity() {
  local account login name email
  account=$(gh api user --jq '.login,
    (if (.name // "") == "" then .login else .name end),
    (if (.email // "") == "" then "\(.id)+\(.login)@users.noreply.github.com" else .email end)' 2>>"$LOG_FILE") ||
    { fail "5/8 Identité git : lecture du compte GitHub impossible, $(details)."; return 1; }
  { read -r login; read -r name; read -r email; } <<<"$account"
  if [[ $(git config --global user.name) == "$name" && $(git config --global user.email) == "$email" ]]; then
    say "5/8 Identité git : déjà réglée sur le compte GitHub $login."
    return 0
  fi
  if ! git config --global user.name "$name" || ! git config --global user.email "$email"; then
    fail "5/8 Identité git : écriture dans $(shown "$HOME/.gitconfig") impossible."
    return 1
  fi
  say "5/8 Identité git : réglée sur le compte GitHub $login."
}

org_repositories() {
  gh api --paginate "orgs/$ORG/repos?per_page=100" --jq '.[] | "\(.name) \(.permissions.push)"' 2>>"$LOG_FILE"
}

clone_repository() {
  local name=$1 partial=$2
  rm -rf "${partial:?}/${name:?}"
  run_logged gh repo clone "$ORG/$name" "$partial/$name" -- --quiet &&
    mv "$partial/$name" "$REPOSITORIES_DIR/$name"
}

clone_repositories() {
  local partial="$REPOSITORIES_DIR.partial" repositories name cloned=0 fetched=0
  local shown_dir
  shown_dir=$(shown "$REPOSITORIES_DIR")
  if ! repositories=$(org_repositories) || [[ -z $repositories ]]; then
    fail "6/8 Dépôts : liste des dépôts de $ORG illisible, $(details)."
    return 1
  fi
  mkdir -p "$REPOSITORIES_DIR" "$partial" ||
    { fail "6/8 Dépôts : création de $shown_dir impossible."; return 1; }
  while read -r name _; do
    if [[ -d $REPOSITORIES_DIR/$name/.git ]]; then
      run_logged git -C "$REPOSITORIES_DIR/$name" fetch --quiet ||
        { fail "6/8 Dépôts : git fetch de $name a échoué, $(details)."; return 1; }
      fetched=$((fetched + 1))
    elif [[ -e $REPOSITORIES_DIR/$name ]]; then
      fail "6/8 Dépôts : $shown_dir/$name existe sans être un clone git, il reste tel quel."
      return 1
    else
      clone_repository "$name" "$partial" ||
        { fail "6/8 Dépôts : clonage de $ORG/$name impossible, $(details)."; return 1; }
      cloned=$((cloned + 1))
    fi
  done <<<"$repositories"
  rmdir "$partial" 2>/dev/null
  if ((cloned == 0)); then
    say "6/8 Dépôts : déjà clonés dans $shown_dir, $fetched mis à jour par git fetch."
  elif ((fetched == 0)); then
    say "6/8 Dépôts : $(counted "$cloned" cloné) dans $shown_dir."
  else
    say "6/8 Dépôts : $(counted "$cloned" cloné), $(counted "$fetched" "déjà présent") et mis à jour par git fetch, dans $shown_dir."
  fi
}

check_ready() {
  local mode=$1 state role repositories name push shown_dir
  shown_dir=$(shown "$REPOSITORIES_DIR")
  read -r state role <<<"$(membership)"
  [[ $state == active ]] ||
    { fail "7/8 Vérification : adhésion à $ORG ${state:-absente}, attendue active."; return 1; }
  if [[ $mode == dev ]]; then
    say "7/8 Vérification : membre de $ORG, rôle $role, état $state."
  fi
  if ! repositories=$(org_repositories) || [[ -z $repositories ]]; then
    fail "7/8 Vérification : liste des dépôts de $ORG illisible, $(details)."
    return 1
  fi
  while read -r name push; do
    [[ $push == true ]] ||
      { fail "7/8 Vérification : pas d'accès en écriture sur $ORG/$name."; return 1; }
    [[ -d $REPOSITORIES_DIR/$name/.git ]] ||
      { fail "7/8 Vérification : clone absent, $shown_dir/$name."; return 1; }
    if [[ $mode == dev ]]; then
      say "7/8 Vérification : $ORG/$name, écriture autorisée, clone présent dans $shown_dir/$name."
    fi
  done <<<"$repositories"
  [[ -f $CONFIGURER ]] ||
    { fail "7/8 Vérification : $(shown "$CONFIGURER") absent du clone du système."; return 1; }
  if [[ $mode == dev ]]; then
    say "7/8 Vérification : $(shown "$CONFIGURER") présent dans le clone du système."
  fi
}

hand_over_to_configurer() {
  local mode=$1 option="" status
  [[ $mode == dev ]] && option=--dev
  say "8/8 Configuration : $(shown "$CONFIGURER") prend la main."
  /bin/bash "$CONFIGURER" ${option:+"$option"} </dev/null
  status=$?
  ((status == 0)) ||
    fail "8/8 Configuration : $(shown "$CONFIGURER") s'est arrêté sur la ligne ci-dessus, code de sortie $status."
}

main() {
  local mode
  case "$#:${1:-}" in
    0:) mode=production ;;
    1:--dev) mode=dev ;;
    1:--help)
      print_head
      return
      ;;
    *)
      fail "Option inconnue : $*. Options acceptées : --dev, --help."
      return 2
      ;;
  esac
  if [[ -e $ASSOCIATE_DIR ]]; then
    fail "Ce Mac porte $(shown "$ASSOCIATE_DIR") : c'est celui d'un associé, déjà installé à la main, et l'installeur n'y touche à rien."
    return 3
  fi
  mkdir -p "${LOG_FILE%/*}" ||
    { fail "Création du journal $(shown "$LOG_FILE") impossible."; return 1; }
  printf '\n== %s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$mode" >>"$LOG_FILE"
  install_homebrew &&
    install_gh &&
    sign_in_to_github &&
    accept_invitation &&
    set_git_identity &&
    clone_repositories &&
    check_ready "$mode" &&
    hand_over_to_configurer "$mode" &&
    say "C'est prêt."
}

main "$@"
