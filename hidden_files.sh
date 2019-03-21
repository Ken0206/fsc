#!/bin/sh
# Description: hidden files
# date: 2019-01-23

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
log=${reportDir}/$(hostname)_hidden_Report.txt
[ -d ${baseLineDir} ] || mkdir -p ${baseLineDir}
base_line=${baseLineDir}/$(hostname)_hidden.txt

[ -e ${baseDir}/exclude_hidden_files ] || touch ${baseDir}/exclude_hidden_files

if [ $(uname) == "Linux" ] ; then
  OS="Linux"
else
  OS="AIX"
fi


find_files() {
  timeStamp=$(date +%Y%m%d_%H%M%S)
  rm -f ${log}
  newFind=${0%/*}/${RANDOM}.temp
  tmpFind=${0%/*}/${RANDOM}.temp
  output_newFind=${reportDir}/$(hostname)_hidden_${timeStamp}.txt
  base_newFind=${0%/*}/${RANDOM}.temp
  #echo '搜尋中 ...'
  find / -name ".*" -type f 2>/dev/null | sort > ${newFind}
  #find / -nouser -ls 2>/dev/null | sort > ${newFind}
  #find / -nouser 2>/dev/null | sort > ${newFind}

  for ex_ in $(cat ${baseDir}/exclude_hidden_files) ; do
    grep -v ${ex_} ${newFind} > ${tmpFind}
    cat ${tmpFind} > ${newFind}
  done

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
      echo "檔案新增數量 : ${addCount}" >> ${report}
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
  rm -f ${t1} ${t2} ${newFind} ${report} ${base_newFind} ${base_line_d} ${tmpFind}
  cat ${log}
}


check_ftime() {
  if [ ${OS} == "Linux" ] ; then
    ftime=$(ls -ld $1 --time-style=full-iso | awk '{print $6" "$7}' | awk -F'.' '{print $1}')
  else
    ftime=$(istat $1 | grep "modified" | awk '{print $8"-"$4"-"$5" "$6}')
  fi

}


find_files

# 刪除60天以上的舊報告
find /src/chkau/report -mtime +60 -type f -exec rm -f {} \;
exit 0

