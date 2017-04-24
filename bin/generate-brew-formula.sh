#! /bin/sh
#
# Generate a formula formulle-xcode-settings stand alone
#
PROJECT="MulleBrew"
TARGET="mulle-brew"
HOMEPAGE="https://www.mulle-kybernetik.com/software/git/${TARGET}"
DESC="Dependency manager for homebrew depedencies"

TAP="${1:-software}"
[ $# -eq 0 ] || shift
VERSION="${1:-`./mulle-brew version`}"
[ $# -eq 0 ] || shift
ARCHIVEURL="${1:-http://www.mulle-kybernetik.com/software/git/${TARGET}/tarball/$VERSION}"
[ $# -eq 0 ] || shift

[ "$VERSION" = "" ] && exit 1
[ "$ARCHIVEURL" = "" ] && exit 1


TMPARCHIVE="/tmp/${PROJECT}-${VERSION}-archive"

if [ ! -f  "${TMPARCHIVE}" ]
then
   curl -L -o "${TMPARCHIVE}" "${ARCHIVEURL}"
   if [ $? -ne 0 -o ! -f "${TMPARCHIVE}" ]
   then
      echo "Download failed" >&2
      exit 1
   fi
else
   echo "using cached file ${TMPARCHIVE} instead of downloading again" >&2
fi

#
# anything less than 17 KB is wrong
#
size="`du -k "${TMPARCHIVE}" | awk '{ print $ 1}'`"
if [ $size -lt 17 ]
then
   echo "Archive truncated or missing" >&2
   cat "${TMPARCHIVE}" >&2
   rm "${TMPARCHIVE}"
   exit 1
fi

HASH="`shasum -p -a 256 "${TMPARCHIVE}" | awk '{ print $1 }'`"

cat <<EOF
class ${PROJECT} < Formula
  homepage "${HOMEPAGE}"
  desc "${DESC}"
  url "${ARCHIVEURL}"
  version "${VERSION}"
  sha256 "${HASH}"

  depends_on "mulle-kybernetik/${TAP}/mulle-bootstrap"

  def install
     system "./install.sh", "#{prefix}"
  end

  test do
  end
end
# FORMULA ${TARGET}.rb
EOF
