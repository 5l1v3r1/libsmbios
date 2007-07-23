#!/bin/sh
# vim:et:ai:ts=4:sw=4:filetype=sh:tw=0:

set -x

cur_dir=$(cd $(dirname $0); pwd)
cd $cur_dir/../

umask 002

[ -n "$LIBSMBIOS_TOPDIR" ] ||
    LIBSMBIOS_TOPDIR=/var/ftp/pub/Applications/libsmbios/

set -e

chmod -R +w _builddir
rm -rf _builddir

mkdir _builddir
pushd _builddir
../configure
make -e distcheck
make -e srpm

. version

popd
git tag -u libsmbios -m "tag for official release: $PACKAGE_STRING" v${PACKAGE_VERSION}
pushd _builddir

DEST=$LIBSMBIOS_TOPDIR/download/${PACKAGE_NAME}/$PACKAGE_STRING/
mkdir -p $DEST
for i in *.tar.{gz,bz2} *.zip *.src.rpm; do
    [ -e $i ] || continue
    [ ! -e $DEST/$(basename $i) ] || continue
    cp $i $DEST
done

/var/ftp/pub/yum/dell-repo/software/_tools/upload_rpm.sh ./${PACKAGE_STRING}-1.src.rpm
