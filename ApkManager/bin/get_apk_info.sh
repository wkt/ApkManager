#!/bin/sh

SED=amsed

info_tmp="/tmp/.info_$USER_$$"
key_file="$2"

test -n "$key_file" || exit 2
localLang=$(echo ${LANG}|${SED} 's|\..*||g')
localLangShort=$(echo ${LANG}|${SED} 's|_.*||g')
test -z "$localLang" &&  localLang=$(echo ${LANGUAGE}|${SED} 's|\..*||g')

shelldir="`dirname $0`"
export PATH="${shelldir}:$PATH"

if aapt dump badging $1 > ${info_tmp} ; then

{
    echo [ApkInfo]
    grep ^package: ${info_tmp} |${SED} -e "s|'||g;s|.*:[\t ]||g"|tr '[\t ]' '\n'
    grep ^application-label: ${info_tmp} |${SED} "s|:[\t ]*'|=|g;s|'||g"
    test -n "$localLang" && grep -E "^application-label-${localLang}:|^application-label-${localLangShort}:" ${info_tmp} \
    | ${SED} "s|:[\t ]*'|=|g;s|'||g"
    grep '^application-icon-[a-zA-Z0-9]*:' ${info_tmp} |${SED} "s|:[\t ]*'|=|g;s|'||g"
    grep application: ${info_tmp} |${SED} "s|.*:||g;s|[ \t]\+label=| application-label=|g;;s|[ \t]\+icon=| application-icon=|g; s|[ \t]\+application-|\napplication-|g;s|'||g"
} > "$key_file"

bigicon=$(grep application-icon- "$key_file" |tail -n1|${SED} 's|.*=||g')
test -n "$bigicon"  && ${SED} -i "s|application-icon=.*|application-icon=$bigicon|g" "${key_file}"
test -n "$localLang" && {
    ${SED} -i "s|^application-label-${localLang}|application-label[${localLang}]|g;s|^application-label-${localLangShort}|application-label[${localLangShort}]|g;" "${key_file}"
}

else
    exit 3
fi

rm -rf ${info_tmp}
