#! /bin/sh
#
# (c) 2017, coded by Nat!, Mulle KybernetiK
#

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


#
# https://github.com/hoelzro/useful-scripts/blob/master/decolorize.pl
#

#
# stolen from:
# http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
# ----
#
_prepend_path_if_relative()
{
   case "$2" in
      /* )
         echo "$2"
         ;;
      * )
         echo "$1/$2"
         ;;
   esac
}


resolve_symlinks()
{
   local dir_context path

   path="`readlink "$1"`"
   if [ $? -eq 0 ]
   then
      dir_context=`dirname -- "$1"`
      resolve_symlinks "`_prepend_path_if_relative "$dir_context" "$path"`"
   else
      echo "$1"
   fi
}


_canonicalize_dir_path()
{
   (
      cd "$1" 2>/dev/null &&
      pwd -P
   ) || exit 1
}


_canonicalize_file_path()
{
    local dir file

    dir="`dirname "$1"`"
    file="`basename -- "$1"`"
    (
      cd "${dir}" 2>/dev/null &&
      echo "`pwd -P`/${file}"
    ) || exit 1
}


canonicalize_path()
{
   if [ -d "$1" ]
   then
      _canonicalize_dir_path "$1"
   else
      _canonicalize_file_path "$1"
   fi
}


realpath()
{
   canonicalize_path "`resolve_symlinks "$1"`"
}


main()
{
   local prefix
   local mode

   prefix=${1:-"/usr/local"}
   [ $# -eq 0 ] || shift
   mode=${1:-755}
   [ $# -eq 0 ] || shift

   if [ -z "${prefix}" ] || [ -z "${mode}" ]
   then
      fail "usage: install.sh [prefix] [mode]"
   fi

   prefix="`realpath "${prefix}" 2> /dev/null`"
   if [ ! -d "${prefix}" ]
   then
      fail "\"${prefix}\" does not exist"
   fi

   local bin

   bin="${prefix}/bin"
   if [ ! -d "${bin}" ]
   then
      mkdir -p "${bin}" || fail "could not create ${bin}"
   fi

   install -m "${mode}" "mulle-brew" "${bin}/mulle-brew" || exit 1
   printf "install: ${C_MAGENTA}${C_BOLD}%s${C_RESET}\n" "${bin}/mulle-brew" >&2
}

main "$@"


