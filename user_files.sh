#!/bin/sh
# Description: search user files
# date: 2019-02-23

if [ ! -f "/src/chkau/export_env" ] ; then
  echo ''
  echo "環境設定檔 /src/chkau/export_env 不存在"
  echo ''
  exit 1
fi
. /src/chkau/export_env
pwd_cmd=$(pwd)
if [ ${baseDir} == ${0%/*} -o ${baseDir} == ${pwd_cmd} ] ; then
  echo '' > /dev/null 2>&1
else
  echo ''
  echo "本 script 必須在 ${baseDir} 路徑下執行"
  echo ''
  exit 1
fi
[ -d ${reportDir} ] || mkdir -p ${reportDir}
log=${reportDir}/$(hostname)_files_list_Report.txt

if [ $(uname) == "Linux" ] ; then
  OS="Linux"
else
  OS="AIX"
fi

aPath='/source/backupUserFiles'
[ -d ${aPath} ] || mkdir -p ${aPath}


search_user_files() {
echo ''
echo '請輸入帳號 :'
echo ''
read user_name
[ -z ${user_name} ] && return
echo '-------------------------------------------------------------' >> ${log}

if [ ${user_name} == "root" ] || [ ${user_name} == "0" ] ; then
  echo '' | tee -a ${log}
  echo 'root 有太多檔案，不搜尋.' | tee -a ${log}
  echo '' | tee -a ${log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a ${log}
  echo '' | tee -a ${log}
  return
fi

id ${user_name} >/dev/null 2>&1
if [ $? -eq 1 ] ; then
  echo '' | tee -a ${log}
  echo "帳號 ${user_name} 不存在!" | tee -a ${log}
  echo '' | tee -a ${log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a ${log}
  echo '' | tee -a ${log}
  return
fi

echo ''
echo '搜尋中 ...'
echo ''
tmp1=${0%/*}/${RANDOM}_temp
u_uid=$(id -u ${user_name})
user_files_log=${0%/*}/${RANDOM}_temp
files=${reportDir}/$(hostname)_files_list_${user_name}_$(date +%Y%m%d_%H%M%S).txt
#userHome=$(grep ${user_name} /etc/passwd | awk -F':' '{print $6}')
#find / -user ${user_name} 2> /dev/null | grep -vE "^/proc|^${userHome}/\." > ${tmp1}  
find / -user ${user_name} -type f 2> /dev/null | sort > ${files}  

echo '' >> ${user_files_log}
echo '帳號: '${user_name}'    UID : '${u_uid} >> ${user_files_log}
echo '' >> ${user_files_log}
echo '所屬檔案清單 : '${files} >> ${user_files_log}
echo '清單內容 :' >> ${user_files_log}

# file name or directory name has a blank character
IFS=$'\n'

if [ -s ${files} ] ; then
  for i in $(cat ${files}) ; do
    check_ftime ${i}
    ls_file=$(ls -ld ${i} | awk '{print $1" "$3" "$4}')
    #echo ${ftime}" "${ls_file}" "$(dirname ${i})"/"$(basename ${i}) >> ${user_files_log}
    echo "${ftime} ${ls_file} $(dirname ${i})/$(basename ${i})" >> ${user_files_log}
  done
  echo '' >> ${user_files_log}
  cat ${user_files_log} | tee -a ${log}
  
else
  echo '' >> ${user_files_log}
  echo "沒有檔案"  >> ${user_files_log}
  echo '' >> ${user_files_log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) >> ${user_files_log}
  echo '' >> ${user_files_log}
  cat ${user_files_log} | tee -a ${log}
  return
fi

echo "警告！ 刪除檔案無法復原！"
echo "請問要刪除上列其中之一的檔案嗎? yes/no (no),  只按 Enter 不刪除."
read del_a
case ${del_a} in
  yes)
    for i in $(cat ${files}) ; do
      echo "是否刪除 ${i} ? yes/no (no)"
      read del_b
      case ${del_b} in
        yes)
          mdir='/tmp/'${user_name}${i%/*}
          [ -d ${mdir} ] || mkdir -p ${mdir}
          mv ${i} ${mdir}
          echo "已刪除."
          echo ''
          echo "已刪除 "${i} >> ${log}
          ;;
        *)
          echo '' > /dev/null
          ;;
      esac
    done
    echo '' >> ${log}
    date_time=$(date +%Y%m%d_%H%M%S)
    aFileName=${aPath}/${date_time}_${user_name}.tar.gz
    cd /tmp
    tar czf ${aFileName} ${user_name} 2>/dev/null
    cd - > /dev/null
    rm -rf /tmp/${user_name}

    ;;
  *)
    echo '' > /dev/null
    ;;
esac

echo $(date +%Y-%m-%d" "%H:%M:%S) >> ${log}
echo '' >> ${log}
rm -f ${tmp1} ${user_files_log}

}


view_log() {
  if [ ! -f ${log} ] ;then
    echo ''
    echo '沒有搜尋紀錄!'
    return
  fi
  cat ${log}
  check_ftime ${log}
  echo ''
  echo '執行紀錄 : '${log}
  echo '檔案時間 : '${ftime}
}


check_ftime() {
  if [ ${OS} == "Linux" ] ; then
    ftime=$(ls -ld $1 --time-style=full-iso | awk '{print $6" "$7}' | awk -F'.' '{print $1}')
  else
    ftime=$(istat $1 | grep "modified" | awk '{print $8"-"$4"-"$5" "$6}')
  fi
}


show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 刪除帳號前檢查及刪檔作業︰搜尋帳號所屬檔案

      2. 執行紀錄

      q. QUIT

EOF
}


main() {
  # The entry for sub functions.
  while true; do
    show_main_menu
    read choice
    case $choice in
    1)
      clear
      search_user_files
      echo ''
      echo "請按Enter鍵繼續"
      read anykey
      ;;
    2)
      clear
      view_log
      echo ''
      echo "請按Enter鍵繼續"
      read anykey
      ;;
    [Qq])
      # 刪除7天以上 user 遭刪除檔案的備份檔
      find ${aPath} -mtime +7 -type f -exec rm -f {} \;

      # 刪除60天以上的舊報告
      find ${reportDir} -mtime +60 -type f -exec rm -f {} \;

      # 報告檔大於 1024000 ，自動刪除 1000 行以前的資料
      if [ $(ls -l ${log} | awk '{print $5}') -gt 1024000 ] ; then
        tmp_log=${0%/*}/${RANDOM}_temp
        tail -1000 ${log} > ${tmp_log}
        cat ${tmp_log} > ${log}
        rm -f ${tmp_log}
        echo '' >> ${log}
        echo '--------------------------------------------------------------------' >> ${log}
        echo "$(date +%Y-%m-%d" "%H:%M:%S) 報告檔大於 1024000，自動刪除 1000 行以前的資料" >> ${log}
        echo '--------------------------------------------------------------------' >> ${log}
        echo '' >> ${log}
      fi 

      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit 0
      ;;
    *)
      echo ''
      ;;
    esac
  done
}


main

