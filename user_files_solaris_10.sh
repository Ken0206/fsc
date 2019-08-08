#!/bin/bash
# Description: search user files
# date: 2019-08-08

rm -f ${0%/*}/*.temp

if [ ! -f "/src/chkau/export_env" ] ; then
  echo ''
  echo "環境設定檔 /src/chkau/export_env 不存在"
  echo ''
  exit 1
fi
. /src/chkau/export_env
pwd_cmd=$(pwd)
if [ "${baseDir}" == "${0%/*}" -o "${baseDir}" == "${pwd_cmd}" ] ; then
  echo '' > /dev/null 2>&1
else
  echo ''
  echo "本 script 必須在 ${baseDir} 路徑下執行"
  echo ''
  exit 1
fi
[ -d ${reportDir} ] || mkdir -p ${reportDir}
log_n=$(hostname)_files_list_Report.txt
log=${reportDir}/${log_n}

if [ "$(uname)" == "Linux" ] ; then
  OS="Linux"
else
  OS="AIX"
fi

typeset -i line_no


search_user_files() {
echo ''
echo '請輸入帳號 :'
echo ''
read user_name
[ -z "${user_name}" ] && return
echo '--------------------------------------------------------------------------------------' >> ${log}

if [ "${user_name}" == "root" ] || [ ${user_name} == "0" ] ; then
  echo '' | tee -a ${log}
  echo 'root 有太多檔案，不搜尋.' | tee -a ${log}
  echo '' | tee -a ${log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a ${log}
  echo '' | tee -a ${log}
  echo "請按Enter鍵繼續"
  read anykey
  return
fi

id ${user_name} >/dev/null 2>&1
if [ "$?" -eq 1 ] ; then
  echo '' | tee -a ${log}
  echo "帳號 ${user_name} 不存在!" | tee -a ${log}
  echo '' | tee -a ${log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a ${log}
  echo '' | tee -a ${log}
  echo "請按Enter鍵繼續"
  read anykey
  return
fi

echo ''
echo '搜尋中 ...'
echo ''
#tmp1=${0%/*}/${RANDOM}_tmp1.temp
u_uid=$(id ${user_name} | awk -F'uid=' '{print $2}' | awk -F'(' '{print $1}')
user_files_log=${0%/*}/${RANDOM}_user_files_log.temp
files_n=$(hostname)_files_list_${user_name}_$(date +%Y%m%d_%H%M%S).txt
files=${reportDir}/${files_n}
#userHome=$(grep ${user_name} /etc/passwd | awk -F':' '{print $6}')
#find / -user ${user_name} 2> /dev/null | grep -vE "^/proc|^${userHome}/\." > ${tmp1}  
find / -user ${user_name} -type f 2> /dev/null | sort > ${files}  

echo '' >> ${user_files_log}
echo '帳號: '${user_name}'    UID : '${u_uid} >> ${user_files_log}
echo '' >> ${user_files_log}
echo '所屬檔案清單 : '${files} >> ${user_files_log}
echo '清單內容 :' >> ${user_files_log}
if [ -s "${files}" ] ; then
  while read file_name ; do
    check_ftime "${file_name}"
    ls_file=$(ls -ld "${file_name}" | awk '{print $1" "$3" "$4}')
    echo "${ftime} ${ls_file} ${file_name}">> ${user_files_log}
  done < ${files}
  echo '' >> ${user_files_log}
  cat ${user_files_log} | tee -a ${log}
  if [ -d "/export/home/dc01" ] ; then
    \cp ${files} /export/home/dc01/
    chown dc01 /export/home/dc01/${files_n}
    chmod 660 /export/home/dc01/${files_n}
  elif [ -d "/export/home/dp01" ] ; then
    \cp ${files} /export/home/dp01/
    chown dc01 /export/home/dp01/${files_n}
    chmod 660 /export/home/dp01/${files_n}
  fi
else
  echo '' >> ${user_files_log}
  echo "沒有檔案"  >> ${user_files_log}
  echo '' >> ${user_files_log}
  echo $(date +%Y-%m-%d" "%H:%M:%S) >> ${user_files_log}
  echo '' >> ${user_files_log}
  cat ${user_files_log} | tee -a ${log}
  echo "請按Enter鍵繼續"
  read anykey
  return
fi
echo "警告！ 刪除檔案無法復原！"
echo "請問要刪除上列其中之一的檔案嗎? yes/no (no),  只按 Enter 不刪除."
read del_ans
lines=$(cat ${files} | wc -l)
exit_while=${lines}+1
tmp_dir_mid="tmp${RANDOM}"
if [ "${del_ans}" == "yes" ] ; then
  line_no=1
  lines=$(cat ${files} | wc -l)
  while [ ${line_no} -le ${lines} ] ; do
    file_name=$(sed -n "${line_no}p" ${files})
    line_no=${line_no}+1
    echo "是否刪除 ${file_name} ? yes/no/q (no)"
    read del_file_ans
    if [ "${del_file_ans}" == "q" ] ; then
      rm -f ${tmp1} ${user_files_log}
      echo $(date +%Y-%m-%d" "%H:%M:%S) >> ${log}
      return
    fi
    if [ "${del_file_ans}" == "yes" ] ; then
      mdir='/tmp/'${tmp_dir_mid}'/'${user_name}$(dirname "${file_name}")'/'
      [ -d "${mdir}" ] || mkdir -p "${mdir}"
      mv "${file_name}" "${mdir}"
      echo "已刪除 ${file_name}" | tee -a ${log}
      echo ''
    fi
  done
  echo '' >> ${log}
  date_time=$(date +%Y%m%d_%H%M%S)
  aPath='/source/backupUserFiles'
  [ -d ${aPath} ] || mkdir -p ${aPath}
  aFileName=${aPath}/${date_time}_${user_name}.tar.gz
  cd /tmp/${tmp_dir_mid}
  tar czf ${aFileName} ${user_name} 2>/dev/null
  cd - > /dev/null
  rm -rf /tmp/${tmp_dir_mid}
fi
echo $(date +%Y-%m-%d" "%H:%M:%S) >> ${log}
echo '' >> ${log}
if [ -d "/export/home/dc01" ] ; then
  \cp ${log} /export/home/dc01/
  chown dc01 /export/home/dc01/${log_n}
  chmod 660 /export/home/dc01/${log_n}
elif [ -d "/export/home/dp01" ] ; then
  \cp ${log} /export/home/dp01/
  chown dc01 /export/home/dp01/${log_n}
  chmod 660 /export/home/dp01/${log_n}
fi

}


view_log() {
  if [ ! -f "${log}" ] ;then
    echo ''
    echo '沒有搜尋紀錄!'
    return
  fi
  cat ${log}
  check_ftime ${log}
  echo ''
  #echo '執行紀錄 : '${log}
  #echo '檔案時間 : '${ftime}
}


check_ftime() {
  if [ "${OS}" == "Linux" ] ; then
    ftime=$(ls -ld "$1" --time-style=full-iso | awk '{print $6" "$7}' | awk -F'.' '{print $1}')
  else
    echo '' > /dev/null
	# non Linux , include AIX, SunOS
    #ftime=$(istat "$1" | grep "modified" | awk '{print $8"-"$4"-"$5" "$6}')
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
      #echo ''
      #echo "請按Enter鍵繼續"
      #read anykey
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
      find /source/backupUserFiles -mtime +7 -type f -exec rm -f {} \;

      # 刪除60天以上的舊報告
      find /src/chkau/report -mtime +60 -type f -exec rm -f {} \;

      rm -f ${tmp1} ${user_files_log}
      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit
      ;;
    *)
      echo '' > /dev/null
      ;;
    esac
  done
}


main

rm -f ${0%/*}/*.temp

