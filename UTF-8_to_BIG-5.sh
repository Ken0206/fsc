#!/bin/sh
# Description: utf8 to big5
# date: 2019-02-21

IFS=$'\n'
dir_='big5'
t1=$(file * | grep 'UTF-8 Unicode text' | awk -F: '{print $1}')
if [ -n "${t1}" ] ; then
  [ -d ${dir_} ] || mkdir ${dir_}
  for i in ${t1} ; do
    iconv -f UTF-8 -t BIG-5 ${i} > ${dir_}/${i}
    echo ${dir_}/${i}
  done
else
  echo -e "\nno UTF-8 files.\n"
fi

