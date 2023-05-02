#!/bin/bash

set -e
src=$1
dst=$2

if test -f $dst/../MacOS/FreeCAD; then
    cp -a $src/MacBundle/* $dst/../
    sed -i '' "s@_FC_BUNDLE_VERSION_@${FMK_BUILD_DATE}@g" $dst/../Info.plist
    mv $dst/../MacOS/FreeCAD $dst/../MacOS/FreeCADLink
elif test -f $dst/MacOS/FreeCAD; then
    cp -a $src/MacBundle/* $dst/
    sed -i '' "s@_FC_BUNDLE_VERSION_@${FMK_BUILD_DATE}@g" $dst/Info.plist
    mv $dst/MacOS/FreeCAD $dst/MacOS/FreeCADLink
elif test -f $dst/bin/FreeCAD; then
    export appid=org.freecadweb.FreeCAD
    export newid=$id.Link
    # duplicate filename containing org.freecadweb.FreeCAD with new name in new id, and replace corresponding content
    find $dst/share/ -type f -name $appid* -exec \
        bash -c 'sed -i s|$appid|$newid| $1 && mv $1 ${1/$appid/$newid}' bash {} \;
    if test -f $dst/../*.desktop; then
        rm -f $dst/../*.desktop $dst/../*.png
        cp $src/AppDir/$newid.* $dst/../
    fi
    cp $src/AppDir/$newid.* $dst/share/
    cp -a $src/icons $dst/share/
    mv $dst/bin/FreeCAD $dst/bin/FreeCADLink
elif test -f  $dst/bin/FreeCAD.exe; then
    mv $dst/bin/FreeCAD.exe $dst/bin/FreeCADLink.exe
else
    echo failed to find bin directory
    exit 1
fi

if test -d $src/Mod; then
    cp -a $src/Mod/* $dst/Mod/
fi

mkdir -p $dst/bin
cp $src/branding/* $dst
mv $dst/branding.xml $dst/bin
if test $FMK_BUILD_DATE; then
    sed -i -e "s@_FC_VERSION_MAJOR_@${FMK_BUILD_DATE:0:4}@g" $dst/bin/branding.xml
    month=${FMK_BUILD_DATE:4:2}
    sed -i -e "s@_FC_VERSION_MINOR_@${month#0}${FMK_BUILD_DATE:6}@g" $dst/bin/branding.xml
    sed -i -e "s@_FC_VERSION_MINOR2_@${FMK_BUILD_DATE:4:2}.${FMK_BUILD_DATE:6}@g" $dst/bin/branding.xml
    sed -i -e "s@_FC_BUILD_DATE_@$FMK_BUILD_DATE@g" $dst/bin/branding.xml
    rm -f "$dst/bin/branding.xml-e"
fi

