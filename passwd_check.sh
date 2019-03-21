#!/bin/sh
# Description: passwd check
# line no. #32, #118, #119
# date: 2019-02-20

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

log=${reportDir}/$(hostname)_passwd_check_Report.txt
[ -d ${reportDir} ] || mkdir -p ${reportDir}

if [ $(uname) == "Linux" ] ; then
  OS="Linux"
else
  OS="AIX"
fi

#OS="AIX"

passwd_check() {
  rm -f ${log}

  if [ ${OS} == "Linux" ] ; then
    # Linux start
    report=${0%/*}/${RANDOM}.temp
    t1=${0%/*}/${RANDOM}.temp
    t2=${0%/*}/${RANDOM}.temp
    t5=${0%/*}/${RANDOM}.temp
    t6=${0%/*}/${RANDOM}.temp
    t7=${0%/*}/${RANDOM}.temp
    touch ${t1} ${t2} ${t5} ${t6} ${t7} ${report}

    awk -F':' '{print $1}' /etc/passwd | sort > ${t5}
    awk -F':' '{print $1}' /etc/shadow | sort > ${t6}
    diff ${t5} ${t6} > ${t7}

    if [ -s ${t7} ] ; then
      echo "/etc/passwd and /etc/shadow 帳號不同步." >> ${report}
      cat ${t7} | grep ">" | awk '{print $2}' > ${t5}
      [ -s ${t5} ] && echo -e "\n"'/etc/shadow 多出以下帳號:' >> ${report} && cat ${t5} >> ${report}
      cat ${t7} | grep "<" | awk '{print $2}' > ${t6}
      [ -s ${t6} ] && echo -e "\n"'/etc/passwd 多出以下帳號:' >> ${report} && cat ${t6} >> ${report}
      echo -e "\n處理帳號同步後，請重新執行此檢查." >> ${report}
    else
      echo -e "\n檢查 /etc/passwd 和 /etc/shadow 帳號同步" >> ${log}

      users=$(grep "^AllowUsers" /etc/ssh/sshd_config | tr ' ' '\n' | grep -v '@' | grep -v AllowUsers)
      if [[ -z "${users}" ]]; then
        users=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
      fi

      for userName in ${users} ; do
        id ${userName} > /dev/null 2>&1
        if [ $? == "0" ] ; then
          userPassword=$(grep "${userName}:" /etc/shadow | awk -F':' '{print $2}')
          userPasswordLen=${#userPassword}
          userPasswordLock=${userPassword:0:1}
          uidNo=$(id -u ${userName})
          if [ ${userPasswordLock} == "!" ]; then
            if [ ${userPasswordLen} -gt 2 ]; then
              echo ${userName} >> ${t1}
            else
              echo ${userName} >> ${t2}
            fi
          fi
        fi
      done

      if [ -s ${t1} ] ; then
        echo -e "\n鎖定帳號:" > ${report}
        cat ${t1} >> ${report}
      else
        echo -e "檢查沒有鎖定帳號" >> ${log}
      fi

      if [ -s ${t2} ] ; then
        echo -e "\n沒有密碼帳號:" >> ${report}
        cat ${t2} >> ${report}
      else
        echo -e "檢查帳號皆有密碼" >> ${log}
      fi

    fi

    echo "" >> ${report}
    cat ${report} >> ${log}
    rm -f ${t1} ${t2} ${t5} ${t6} ${t7} ${report} ${user_list_file}
    # Linux end

  else

    # AIX start
    report=${0%/*}/report.${RANDOM}.temp
    f1=${0%/*}/f1.${RANDOM}.temp
    f2=${0%/*}/f2.${RANDOM}.temp
    t1=${0%/*}/t1.${RANDOM}.temp
    t2=${0%/*}/t2.${RANDOM}.temp
    t3=${0%/*}/t3.${RANDOM}.temp
    t4=${0%/*}/t4.${RANDOM}.temp
    t5=${0%/*}/t5.${RANDOM}.temp

    pwdck -n ALL > ${f1} 2>&1
    users=$(lsuser ALL 2>&1 | grep rlogin=true | awk '{print $1}')
    #cat ${0%/*}/reference/pwdck_n_ALL.txt > ${f1}
    #users=$(cat ${0%/*}/reference/lsuser_ALL | grep rlogin=true | awk '{print $1}')
    if [[ -z "${users}" ]]; then
      users=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
    fi

    for i in ${users} ; do
      g_str="\"${i}\""
      grep ${g_str} ${f1} >> ${f2}
    done
    echo '' >> ${f2}
    cat ${f2} > ${f1}

    grep "3001-402" ${f1} | awk -F'"' '{print $2}' > ${t1}
    sed '/^$/d' ${t1} > ${f2}
    cat ${f2} > ${t1}
    grep "3001-414" ${f1} | awk -F'"' '{print $2}' > ${t2}
    sed '/^$/d' ${t2} > ${f2}
    cat ${f2} > ${t2}
    grep "3001-421" ${f1} | awk -F'"' '{print $2}' > ${t3}
    sed '/^$/d' ${t3} > ${f2}
    cat ${f2} > ${t3}
    grep "3001-403" ${f1} > ${t4}
    grep "3001-422" ${f1} > ${t5}

    [ -s ${t4} ] && cat ${t4} >> ${report} && echo >> ${report}
    [ -s ${t5} ] && cat ${t5} >> ${report} && echo >> ${report}
    if [ -s ${t1} ] ; then
      echo "Invalid password field in /etc/passwd users list:" >> ${report}
      cat ${t1} >> ${report}
      echo >> ${report}
    fi
    if [ -s ${t2} ] ; then
      echo "Stanza not found in /etc/security/passwd users list:" >> ${report}
      cat ${t2} >> ${report}
      echo >> ${report}
    fi
    if [ -s ${t3} ] ;then
      echo "Not have a stanza in /etc/security/user users list:" >> ${report}
      cat ${t3} >> ${report}
      echo >> ${report}
    fi
    if [ ! -s ${report} ] ; then
      echo "查無問題之帳號." >> ${report}
    fi

    echo '' >> ${log}
    echo 'pwdck -n ALL 分析結果:' >> ${log}
    echo >> ${log}
    cat ${report} >> ${log}
    rm -f ${f1} ${f2} ${t1} ${t2} ${t3} ${t4} ${t5} ${report}
    # AIX end

  fi
  echo '' >> ${log}
  echo '本報告檔案 : '${log} >> ${log}
  check_ftime ${log}
  echo ' 檔案時間  : '${ftime} >> ${log}
  echo '' >> ${log}
  cat ${log}
}


check_ftime() {
  if [ ${OS} == "Linux" ] ; then
    ftime=$(ls -ld $1 --time-style=full-iso | awk '{print $6" "$7}' | awk -F'.' '{print $1}')
  else
    ftime=$(istat $1 2>/dev/null | grep "modified" | awk '{print $8"-"$4"-"$5" "$6}')
  fi

}


passwd_check

# 刪除60天以上的舊報告
find ${reportDir} -mtime +60 -type f -exec rm -f {} \;
exit 0

