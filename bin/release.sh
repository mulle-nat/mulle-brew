#! /bin/sh

TAP="${1:-software}"
[ $# -ne 0 ] && shift
BRANCH="${1:-release}"
[ $# -ne 0 ] && shift
TAG="${1:-`./mulle-brew version`}"
[ $# -ne 0 ] && shift


if [ "${MULLE_BOOTSTRAP_NO_COLOR}" != "YES" ]
then
   # Escape sequence and resets
   C_RESET="\033[0m"

   # Useable Foreground colours, for black/white white/black
   C_RED="\033[0;31m"     C_GREEN="\033[0;32m"
   C_BLUE="\033[0;34m"    C_MAGENTA="\033[0;35m"
   C_CYAN="\033[0;36m"

   C_BR_RED="\033[0;91m"
   C_BOLD="\033[1m"

   #
   # restore colors if stuff gets wonky
   #
   trap 'printf "${C_RESET} >&2 ; exit 1"' TERM INT
fi


fail()
{
   printf "${C_BR_RED}Error: $*${C_RESET}\n" >&2
   exit 1
}


git_must_be_clean()
{
   local name
   local clean

   name="${1:-${PWD}}"

   if [ ! -d .git ]
   then
      fail "\"${name}\" is not a git repository"
   fi

   clean=`git status -s --untracked-files=no`
   if [ ! -z "${clean}" ]
   then
      fail "repository \"${name}\" is tainted"
   fi
}


[ -d "../homebrew-$TAP" ] || fail "tap $TAP is invalid"

git_must_be_clean

devbranch="`git rev-parse --abbrev-ref HEAD`"

(
   git checkout "${BRANCH}"    &&
   git rebase "${devbranch}"   &&
   git push public "${BRANCH}"
) || exit 1


# seperate step, as it's tedious to remove tag when
# previous push fails

(
   git tag "${TAG}"                    &&
   git push public "${BRANCH}" --tags  &&
   git push github "${BRANCH}" --tags
) || exit 1


./bin/generate-brew-formula.sh "${TAP}" > ../homebrew-$TAP/mulle-brew.rb
(
	cd ../homebrew-$TAP ; \
   git add mulle-brew.rb ; \
 	git commit -m "${TAG} ${BRANCH} of mulle-brew" mulle-brew.rb ; \
 	git push origin master
)

git checkout "${devbranch}"
