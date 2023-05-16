#!/bin/bash

set -xe
src=$1
dst=$2
branddir=${3:-$dst}
postfix=$FMK_DESKTOP_ID_POSTFIX
date=${FMK_BUILD_DATE:=`date +%Y%m%d`}

mdst=$dst
if test -f $dst/../Info.plist; then
    mdst=$dst/..
fi
if test -f $mdst/Info.plist; then
    cp -a $src/MacBundle/* $mdst/
    sed -i '' "s@_FC_BUNDLE_VERSION_@${date}@g" $mdst/Info.plist
    mv $mdst/Resources/bin/FreeCAD $mdst/Resources/bin/FreeCADLink
elif test -f  $dst/bin/FreeCAD.exe; then
    mv $dst/bin/FreeCAD.exe $dst/bin/FreeCADLink.exe
elif test -f $dst/bin/FreeCAD && test -d $dst/share; then
    appid=org.freecadweb.FreeCAD
    newid=$appid.Link
    destid=$newid$postfix
    # duplicate filename containing org.freecadweb.FreeCAD with new name in new id, and replace corresponding content
    find $dst/share/ -type f -name $appid* -exec \
        bash -c "sed 's|$appid|$destid|' "'$1 > ${1/'"$appid/$newid} && rm -f "'$1' bash {} \;
    if test -f $dst/../*.desktop; then
        rm -f $dst/../*.desktop $dst/../*.png
        for f in $src/AppDir/$newid.*; do
            name=$(basename $f)
            cp $f $dst/../${name/$newid/$destid}
        done
    fi
    appdir=$dst/share/applications
    mkdir -p $appdir
    rm -f $appdir/$appid.desktop $appdir/$appid.png
    cp $src/AppDir/$newid.* $appdir
    cp -a $src/icons $dst/share/
    mv $dst/bin/FreeCAD $dst/bin/FreeCADLink

    if test $postfix; then
        for f in $(find $dst/share -type f -name "$newid.*"); do
            mv $f ${f/$newid/$destid}
        done
    fi
else
    echo failed to find bin directory
    exit 1
fi

if test -d $src/Mod; then
    cp -a $src/Mod/* $dst/Mod/
fi

mkdir -p $branddir
cp $src/branding/* $branddir/
sed -i -e "s@_FC_VERSION_MAJOR_@${date:0:4}@g" $branddir/branding.xml
month=${date:4:2}
sed -i -e "s@_FC_VERSION_MINOR_@${month#0}${date:6}@g" $branddir/branding.xml
sed -i -e "s@_FC_VERSION_MINOR2_@${date:4:2}.${date:6}@g" $branddir/branding.xml
sed -i -e "s@_FC_BUILD_DATE_@$date@g" $branddir/branding.xml
rm -f "$branddir/branding.xml-e"
! test -d $branddir/bin || cp $branddir/branding.xml $branddir/bin

