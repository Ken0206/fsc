#!/bin/sh
# date : 2019-04-08
# line  #23  #56  #71
#
# 建置帳號對程式及資料檔案相關權限之檢查功能介面，於帳號清查作業時一併列示清查
# 使用前請先定義 以下參數
# DIRECTORY_YOU_WANT_TO_CHECK_PERMISSION  #掃描這些目錄下所有檔案與目錄的權限

DIRECTORY_YOU_WANT_TO_CHECK="/home /source /tmp"

_HOME="/src/chkau/report"
[ -d ${_HOME} ] || mkdir -p ${_HOME}
typeset -i x=0
ACCESS_REPORT="$_HOME/ACCESS_report_$(hostname)_$(date +%Y%m%d).txt"
cat /dev/null > $ACCESS_REPORT

if [[ "$(uname)" = "Linux" ]]; then
  OS="Linux"
else
  OS="AIX"
fi

#OS="AIX"

show_main_menu() {
  # Just show main menu.
  clear
  cat <<EOF
  +====================================================================+
       非系統帳號對業務程式及資料檔案之相關權限查詢
       Hostname: $(hostname), Today is $(date +%Y-%m-%d)
  +====================================================================+

      1. 執行帳號權限檢查。將結果寫入 ${ACCESS_REPORT}
      2. 列出執行結果

      q.QUIT

EOF
}

list_dirs_permissions_by_user() {
  # example
  # 
  # spos2    read       exec /home

  if [[ "$OS" = "Linux" ]]; then
    ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | tr ' ' '\n' | grep -v '@' | grep -v AllowUsers )
  else

    ex_ids=$(grep "^AllowUsers" /etc/ssh/sshd_config | tr ' ' '\n' | grep '@' | awk -F@ '{print $1}' | sort | uniq)

    tmp_ids1=${0%/*}/tmp_ids1.${RANDOM}.temp
    tmp_ids2=${0%/*}/tmp_ids2.${RANDOM}.temp
    lsuser ALL 2> /dev/null | grep rlogin=true | awk '{print $1}' > ${tmp_ids1}
    #cat /src/chkau/reference/lsuser_ALL_permission | grep rlogin=true | awk '{print $1}' > ${tmp_ids1}

    for i in ${ex_ids} ; do
      grep -v ${i} ${tmp_ids1} > ${tmp_ids2}
      cat ${tmp_ids2} > ${tmp_ids1}
    done
    ids=$(cat ${tmp_ids1})
    rm -f ${tmp_ids1} ${tmp_ids2}

  fi

  if [[ -z "${ids}" ]]; then
    ids=$(cat /etc/passwd | awk -F':' '/.*sh$/  {print $1}')
  fi

  #echo "Please wait..."
  echo "                                 使用者對重要系統伺服器重要業務檔案與程式權限清查" >>$ACCESS_REPORT
  echo '' >>$ACCESS_REPORT
  echo HOSTNAME: $(hostname) "    " TIME: $(date +%Y/%m/%d) $(date +%H:%M:%S) >>$ACCESS_REPORT
  echo "" >>$ACCESS_REPORT

  check_1=0
  for i in ${DIRECTORY_YOU_WANT_TO_CHECK} ; do
    if [ -d "${i}" ] ; then
      check_t="${check_t} ${i}"
    else
      if [ "${check_1}" -eq 0 ] ; then
        #echo "${i} 不存在！  請確認 DIRECTORY_YOU_WANT_TO_CHECK 設定值" >>$ACCESS_REPORT
        echo "本伺服器無重要業務檔案路徑" >>$ACCESS_REPORT
        check_1=1
      fi
    fi
  done

  DIRECTORY_YOU_WANT_TO_CHECK="${check_t}"

  check_box="                          口續用口不續用，將開單刪除"
  step_n=29

  for id in $ids; do
    echo '' >>$ACCESS_REPORT
    echo "  帳號     讀取    寫入  執行        檔案或程式路徑                  負責科別    持有人簽章   續用/不續用，將開單刪除" >>$ACCESS_REPORT
    for _dir in $DIRECTORY_YOU_WANT_TO_CHECK; do
      _readable=""
      _writable=""
      _execable=""
      su $id -c "test -r '$_dir'" >/dev/null 2>&1 && _readable="read"
      su $id -c "test -w '$_dir'" >/dev/null 2>&1 && _writable="write"
      su $id -c "test -x '$_dir'" >/dev/null 2>&1 && _execable="exec"

      if ! [[ $_readable = "" && $_writable = "" && $_execable = "" ]]; then

        echo "======================================================================================================================" >>$ACCESS_REPORT

        x=0
        wc_=${#_dir}
        while [ "${wc_}" -gt "${x}" ] ; do
          if [[ "$OS" = "Linux" ]]; then
            sub_chr=${_dir:${x}:${step_n}}
          else
            sub_chr=$(echo ${_dir} | cut -c${x}-${step_n})
          fi
          if [ "${x}" -eq 0 ] ; then
            printf "%-10s %-7s %-5s %-10s %-29s %-s \n" $id "$_readable" "$_writable" "$_execable" "${sub_chr}" "${check_box}" >>$ACCESS_REPORT
          else
            printf "%-35s %-s \n" " " "${sub_chr}" >>$ACCESS_REPORT
          fi
          echo '' >>$ACCESS_REPORT
          x=${x}+${step_n}
        done

      else

        x=0
        #wc_=${#_dir}
        #while [ "${wc_}" -gt "${x}" ] ; do
        #  if [[ "$OS" = "Linux" ]]; then
        #    sub_chr=${_dir:${x}:${step_n}}
        #  else
        #    sub_chr=$(echo ${_dir} | cut -c${x}-${step_n})
        #  fi
        #  if [ "${x}" -eq 0 ] ; then
        #    printf "%-10s %-27s %-29s \n" $id "無 read write exec 權限" "${sub_chr}" >>$ACCESS_REPORT
        #  else
        #    printf "%-35s %-s \n" " " "${sub_chr}" >>$ACCESS_REPORT
        #  fi
        #  x=${x}+${step_n}
        #done

      fi

      #sub_dirs=$(ls -la $_dir | grep "^d" | awk '{print $NF}' | grep -v "^\.")
      #for sub_dir in $sub_dirs; do
      #  _readable=""
      #  _writable=""
      #  _execable=""
      #  su $id -c "test -r '$_dir/$sub_dir'" >/dev/null 2>&1 && _readable="read"
      #  su $id -c "test -w '$_dir/$sub_dir'" >/dev/null 2>&1 && _writable="write"
      #  su $id -c "test -x '$_dir/$sub_dir'" >/dev/null 2>&1 && _execable="exec"
      #  if ! [[ $_readable = "" && $_writable = "" && $_execable = "" ]]; then

      #    x=0
      #    _dir2="$_dir/$sub_dir"
      #    wc_=${#_dir2}
      #    while [ "${wc_}" -gt "${x}" ] ; do
      #      if [[ "$OS" = "Linux" ]]; then
      #        sub_chr=${_dir2:${x}:${step_n}}
      #      else
      #        sub_chr=$(echo ${_dir2} | cut -c${x}-${step_n})
      #      fi
      #      if [ "${x}" -eq 0 ] ; then
      #        printf "%-10s %-7s %-5s %-10s %-29s %-s \n" $id "$_readable" "$_writable" "$_execable" "${sub_chr}" "${check_box}" >>$ACCESS_REPORT
      #      else
      #        printf "%-35s %-s \n" " " "${sub_chr}" >>$ACCESS_REPORT
      #      fi
      #      x=${x}+${step_n}
      #    done

      #  fi
      #done
    done
  done
}

list_last_ACCESS_REPORT() {
  if [ -f $ACCESS_REPORT ]; then
    cat $ACCESS_REPORT
    return
  else
    echo "沒有今天的報告。"
    return
  fi

  reports=$(ls -tr ACCESS_*)

  if [ -z "${reports}" ]; then
    echo "未產生過報告，請執行選項 1。"
    return
  fi

  last_report=$(ls -tr ACCESS_* | tail -1)
  cat $last_report

}

main() {
  # The entry for sub functions.
  while true; do
    cd ${_HOME}
    show_main_menu
    read choice
    clear
    case $choice in
    1) list_dirs_permissions_by_user ;;
    2) list_last_ACCESS_REPORT ;;
    [Qq])
      echo ''
      echo 'Thanks !! bye bye ^-^ !!!'
      echo ''
      exit
      logout
      ;;
    *)
      clear
      echo ''
      echo ' !!!  ERROR CHOICE , PRESS ENTER TO CONTINUE ... !!!'
      read choice
      ;;
    esac
    echo ''
    echo 'Press enter to continue' && read null
  done
}

#main
list_dirs_permissions_by_user

