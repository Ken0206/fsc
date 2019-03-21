#!/bin/sh
# Description: nouser files
# date: 2019-01-14

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
log=${reportDir}/$(hostname)_nouser_Report.txt
[ -d ${baseLineDir} ] || mkdir -p ${baseLineDir}
base_line=${baseLineDir}/$(hostname)_nouser.txt

if [ $(uname) == "Linux" ] ; then
  OS="Linux"
else
  OS="AIX"
fi


find_files() {
  timeStamp=$(date +%Y%m%d_%H%M%S)
  rm -f ${log}
  newFind=${0%/*}/${RANDOM}.temp
  output_newFind=${reportDir}/$(hostname)_nouser_${timeStamp}.txt
  base_newFind=${0%/*}/${RANDOM}.temp
  #echo '搜尋中 ...'
  #find / -name ".*" 2>/dev/null | sort > ${newFind}
  #find / -nouser -ls 2>/dev/null | sort > ${newFind}
  find / -nouser -type f 2>/dev/null | sort > ${newFind}
  newFindCount=$(cat ${newFind} | wc -l)
  
  echo "   日期      時間      權限     UID   GID     完整路徑" >> ${output_newFind}
  echo "-------------------------------------------------------------------" >> ${output_newFind}
  for i in $(cat ${newFind}) ; do
    if [ -f ${i} ] || [ -d ${i} ] ; then
      check_ftime ${i}
      ls_file=$(ls -ld ${i} | awk '{print $1" "$3" "$4" "$9}')
      echo ${ftime}" "${ls_file}  >> ${base_newFind}
    fi
  done
  cat ${base_newFind} >> ${output_newFind}
  echo "-------------------------------------------------------------------" >> ${output_newFind}
  echo "   日期      時間      權限     UID   GID     完整路徑" >> ${output_newFind}
  echo '' >> ${output_newFind}
  echo "  Total  : ${newFindCount}" >> ${output_newFind}

  report=${0%/*}/${RANDOM}.temp
  if [ ! -f ${base_line} ] ; then
    cat ${base_newFind} > ${base_line}
    echo '' >> ${report}
    echo "查無基準檔，建立基準檔" >> ${report}
  else
    base_line_d=${0%/*}/${RANDOM}.temp
    awk '{print $6}' ${base_line} | sort > ${base_line_d}
    t1=${0%/*}/${RANDOM}.temp
    t2=${0%/*}/${RANDOM}.temp
    diff ${base_line_d} ${newFind} | grep "^<" | awk '{print $2}' >> ${t1}
    delCount=$(cat ${t1} | wc -l)
    if [ -s ${t1} ] 
    then 
      echo '' >> ${report}
      echo "檔案減少數量 : ${delCount}" >> ${report}
      echo "減少清單 :" >> ${report}
      cat ${t1} >> ${report}
    fi
    diff ${base_line_d} ${newFind} | grep "^>" | awk '{print $2}' >> ${t2}
    addCount=$(cat ${t2} | wc -l)
    if [ -s ${t2} ]
    then
      echo '' >> ${report}
      echo "比基準檔 新增數量 : ${addCount}" >> ${report}
      echo "新增清單 :" >> ${report}
      echo "   日期      時間      權限     UID   GID     完整路徑" >> ${report}
      echo "-------------------------------------------------------------------" >> ${report}
      for i in $(cat ${t2}) ; do
        check_ftime ${i}
        ls_file=$(ls -ld ${i} | awk '{print $1" "$3" "$4" "$9}')
        echo ${ftime}" "${ls_file}  >> ${report}
      done
      echo "-------------------------------------------------------------------" >> ${report}
      echo "   日期      時間      權限     UID   GID     完整路徑" >> ${report}
    fi
    rm -f ${t1} ${t2}
    noFlag=1
    if [ ! -s ${report} ]
    then
      noFlag=0
      echo '' >> ${report}
      echo "與基準檔比對相同，沒有新增減少" >> ${report}
    fi
  #cat ${base_line_d} > ${base_line}
  fi

  check_ftime ${base_line}
  echo '' >> ${report}
  echo "基 準 檔 : ${base_line}" >> ${report}
  echo "檔案時間 : ${ftime}" >> ${report}
  echo "  Total  : $(cat ${base_line} | wc -l)" >> ${report}

  check_ftime ${output_newFind}
  echo '' >> ${report}
  echo "目前搜尋結果檔案清單 : "${output_newFind} >> ${report}
  echo "檔案時間 : ${ftime}" >> ${report}
  echo "  Total  : ${newFindCount}" >> ${report}

  echo '' >> ${report}
  echo '本報告檔案 : '${log} >> ${report}
  echo '' >> ${report}

  cat ${report} >> ${log}
  rm -f ${t1} ${t2} ${newFind} ${report} ${base_line_d} ${base_newFind}
  cat ${log}
}


check_ftime() {
  if [ ${OS} == "Linux" ] ; then
    ftime=$(ls -ld $1 --time-style=full-iso | awk '{print $6" "$7}' | awk -F'.' '{print $1}')
  else
    ftime=$(istat $1 | grep "modified" | awk '{print $8"-"$4"-"$5" "$6}')
  fi

}


view_log() {
  if [ ! -f ${log} ] ;then
    echo ''
    echo '沒有搜尋紀錄!'
    return
  fi
  cat ${log}
}


view_base_line() {
  if [ ! -f ${base_line} ] ;then
    echo ''
    echo '沒有基準檔!'
    return
  else
    clear
    if [ -s ${base_line} ] ; then
      echo "   權限     UID   GID   完整路徑"
      echo "--------------------------------------------------"
      for i in $(cat ${base_line}) ; do
        if [ -f ${i} ] || [ -d ${i} ] ; then
          ls -ld ${i} | awk '{print $1" "$3" "$4" "$9}'
        fi
      done
      echo "--------------------------------------------------"
      echo "   權限     UID   GID   完整路徑"
    else
      echo ''
      echo '基準檔內容為空'
    fi
    echo ''
    check_ftime ${base_line}
    echo '基 準 檔 : '${base_line}
    echo '建檔時間 : '${ftime}
    echo '  Total  : '$(cat ${base_line} | wc -l)
  fi

}


show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 搜尋 nouser 檔案

      2. 上次搜尋紀錄

      3. 顯示基準檔

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
      find_files
      echo ''
      echo "請按Enter鍵繼續"
      read anykey
      ;;
    2)
      view_log
      echo ''
      echo "請按Enter鍵繼續"
      read anykey
      ;;
    3)
      view_base_line
      echo ''
      echo "請按Enter鍵繼續"
      read anykey
      ;;
    [Qq])
      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit
      ;;
    *)
      echo ''
      ;;
    esac
  done
}


find_files
# 刪除60天以上的舊報告
find /src/chkau/report -mtime +60 -type f -exec rm -f {} \;
exit 0
