######################################################
# Script        : iso_chk_aix.sh
# Describption  : TCB AIX Security
#                 please chmod 755
# Version       : 1.2
# Date          : 20121001
# Create By     : SPCWS
# Modeify By    : Nicky Huang
######################################################
#!/bin/ksh
wrkdir="/src/chkau"
hname=`hostname`
#outfil=/$wrkdir/$hname.iso_chk.txt.$(date +%F-%H%M)
outfil="${wrkdir}/$hname.iso_chk.txt.$(date +%F)"
echo "#########" > $outfil
echo "#附 件 #" >> $outfil
echo "#########" >> $outfil
echo " " >> $outfil
echo " " >> $outfil
echo  `hostname` "AIX系統強化檢核表附件" >> $outfil
echo " "  >> $outfil
echo " " >> $outfil
echo "1. 移除登錄畫面上之重要系統資訊" >> $outfil
echo "1-1 登錄畫面的welcome message是否含有系統資訊" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/security/login.cfg" >> $outfil
echo " 確認登錄畫面訊息 herald= Unauthorized use of this system is prohibited." >> $outfil
echo " 確認 logindelay=5 " >> $outfil
cat /etc/security/login.cfg|grep -v '*'|head -10 >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2. 使用者的安全管理" >> $outfil
echo "2-1 確認密碼品質的設定是否依照公司政策設定" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/security/user |grep -v '^*' "  >> $outfil
cat /etc/security/user|grep -v "^*" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-2 確認root帳號之管理是否適當" >> $outfil
echo "==================================" >> $outfil
echo "2.2.1 確認root帳號已經由系統管理科回收持有" >> $outfil
echo "root帳號已由系統管理科回收持有" >> $outfil
echo "----------------------------------" >> $outfil
echo "2.2.2 確認/etc/passwd, root之 uid 和 gid " >> $outfil
echo "cat /etc/passwd|grep '0:0' "  >> $outfil
cat /etc/passwd |grep '0:0'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.3 列出/etc/passwd中,uid及gid為0的所有使用者,並檢查是否適當" >> $outfil
echo "cat /etc/passwd|grep '0:0' "  >> $outfil
cat /etc/passwd |grep '0:0'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.4 檢查root 之 rlogin=false 防止遠端直接登入 " >> $outfil
echo "cat /etc/security/user " >> $outfil
cat /etc/security/user |egrep "root|rlogin" |grep -v "^*" |head -3 >> $outfil
echo "lsuser -a rlogin root " >> $outfil
lsuser -a rlogin root >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.5 檢查root 是否有指定安全搜尋路徑" >> $outfil
echo 'echo $PATH '  >> $outfil
echo  $PATH >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-3 確認其他系統預設帳號是否必要存在" >> $outfil
echo "==================================" >> $outfil
echo "2.3.1 檢查帳號列表，是否留有如 guest, uucp, nuucp 和 lpd 帳號並鎖定" >> $outfil
echo "lsuser -a -f account_locked guest " >> $outfil
lsuser -a -f account_locked guest 2>> $outfil 1>>$outfil
echo "---------   ----------  ----------- " >> $outfil
echo "lsuser -a -f account_locked uucp " >> $outfil
lsuser -a -f account_locked uucp 2>> $outfil 1>>$outfil
echo "---------   ----------  ----------- " >> $outfil
echo "lsuser -a -f account_locked nuucp " >> $outfil
lsuser -a -f account_locked nuucp 2>> $outfil 1>>$outfil
echo "---------   ----------  ----------- " >> $outfil
echo "lsuser -a -f account_locked lpd " >> $outfil
lsuser -a -f account_locked lpd 2>> $outfil 1>>$outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.3.2 列示確認廠商使用之帳號"  >> $outfil
echo "無廠商使用之帳號"  >> $outfil
#echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 > 200 {print \$1}'|grep -v nobody|grep -v ipsec" >> $outfil
#cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 > 200 {print $1}'|grep -v nobody|grep -v ipsec >> $outfil
echo "----------------------------------" >> $outfil
echo "2.3.3 列示所有系統預設帳號 "  >> $outfil
echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 <= 300 {print \$1}'" >> $outfil
cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 <= 300 {print $1}' >> $outfil
echo "----------------------------------" >> $outfil
echo "2.3.4 檢查/etc/passwd "  >> $outfil
echo "cat /etc/passwd "  >> $outfil
cat /etc/passwd |grep -v '^#'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "  " >> $outfil

echo "2-4 確認強迫使用者未作任何動作超過一定時間時，予以強迫登出。" >> $outfil
echo "==================================" >> $outfil
echo "檢查/etc/profile是否設有 TMOUT 參數 900=15 minutes " >> $outfil
echo "cat /etc/profile|grep TMOUT"  >> $outfil
cat /etc/profile |grep TMOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-5 確認使用者不可變更/etc/profile設定檔" >> $outfil
#echo "2-5 確認只有系統管理者可變更/etc/profile設定檔" >> $outfil
echo "==================================" >> $outfil
echo " 確認 /etc/profile 使用者無變更權限"  >> $outfil
echo "ls -l /etc/profile "  >> $outfil
ls -l /etc/profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-6 確認系統預設使用者帳號的umask值為027" >> $outfil
echo "==================================" >> $outfil
echo "確認系統預設使用者帳號 umask 值，一般使用者帳號可為022 " >> $outfil
echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 <= 300 {system("lsuser -a -f umask " $1)}'" >> $outfil
cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 <= 300 {system("lsuser -a -f umask " $1)}' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-7 確認使用者代碼之密碼檔" >> $outfil
echo "==================================" >> $outfil
echo "檢查使用者代碼之密碼檔" >> $outfil
 /src/chkau/passwd_check.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-8 確認隱藏檔是否適當？" >> $outfil
echo "==================================" >> $outfil
echo "檢查應用程式所在路徑下之隱藏檔是否適當 " >> $outfil
    /src/chkau/hidden_files.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-9 確認NoUser之檔案？" >> $outfil
echo "==================================" >> $outfil
echo "檢查應用程式所在路徑下NoUser之檔案是否適當 " >> $outfil
    /src/chkau/nouser_files.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "3-1 確認/etc/hosts.equiv、 rhosts、.netrc存在之必要性" >> $outfil
echo "==================================" >> $outfil
echo "find /home -name .rhosts -print"  >> $outfil
find /home -name .rhosts -print |grep -v old  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "find /home -name .netrc -print "  >> $outfil
find /home -name .netrc -print |grep -v old  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "pg /etc/hosts.equiv "  >> $outfil
pg /etc/hosts.equiv |grep -v  '^#' >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "  " >> $outfil

echo "3-2 確認限制root帳號只能由Console登入"  >> $outfil
echo "==================================" >> $outfil
echo "lsuser -a -f login rlogin root "  >> $outfil
lsuser -a -f login rlogin root  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-1 確認系統之稽核功能已經啟動"  >> $outfil
echo "==================================" >> $outfil
echo "4.1.1應開啟稽核模式 binmode=on 或 streammode=on ">> $outfil
echo "cat  /etc/security/audit/config|head -4  "  >> $outfil
cat /etc/security/audit/config|head -4  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "4.1.2 確保特殊權限帳號所引發事件皆有記錄，如 Users: root=general " >> $outfil
echo "cat  /etc/security/audit/config|grep root" >> $outfil
cat  /etc/security/audit/config|grep root  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-2 確認系統重要目錄或物件稽核紀錄已啟動"  >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/security/audit/objects "  >> $outfil
cat /etc/security/audit/objects >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-3 確認稽核設定檔權限"  >> $outfil
echo "==================================" >> $outfil
echo "應確保/etc/security/audit 目錄下所有稽核設定檔僅有root 可存取" >> $outfil
echo "ls -lR /etc/security/audit " >> $outfil
chmod 600 /aulog/bin1
chmod 600 /aulog/bin2
ls -lR /etc/security/audit  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-4 確認系統稽核log檔權限"  >> $outfil
echo "==================================" >> $outfil
echo "ls -ld /aulog  "  >> $outfil
ls -ld /aulog   >> $outfil
echo "----------------------------------" >> $outfil
echo "ls -l /aulog  "  >> $outfil
ls -l /aulog   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-5 確認系統稽核日誌自動開啟設定"  >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/inittab |grep audit " >> $outfil
cat /etc/inittab |grep audit  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "5-1 確認路徑之設定環境變數"  >> $outfil
echo "==================================" >> $outfil
echo 'su - root "-c env| grep PATH "'  >> $outfil
su - root "-c env| grep PATH"   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "5-2 確認cron和at Jobs設定之適當性" >> $outfil
echo "==================================" >> $outfil
echo "5.2.1確認cron.allow及at.allow 只有root名列其中" >> $outfil
echo "cat /var/adm/cron/cron.allow "  >> $outfil
cat /var/adm/cron/cron.allow  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "cat /var/adm/cron/at.allow "  >> $outfil
cat /var/adm/cron/at.allow  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "5.2.2檢視var/adm/cron是否有cron.deny及at.deny之檔案 " >> $outfil
echo "ls -l /var/adm/cron|grep deny" >> $outfil
ls -l /var/adm/cron|grep deny >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "  " >> $outfil


echo "5-3 確認Cron control file (/var/spool/cron/crontabs/*)是否經適當保護" >> $outfil
echo "==================================" >> $outfil
echo "5.3.1 檢查其檔案權限" >> $outfil
echo "ls -l /var/spool/cron/crontabs/ " >> $outfil
ls -l /var/spool/cron/crontabs/ >> $outfil
echo "----------------------------------" >> $outfil
echo "5.3.2 以cronadm cron -l 清查所有的cron job 是否適當" >> $outfil
echo "cronadm cron -l|grep -v '^#' " >> $outfil
cronadm cron -l|grep -v '^#'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-1 移除不必要的系統服務"  >> $outfil
echo "==================================" >> $outfil
echo "6.1.1 確認開啟的通訊埠及TCP/IP服務適當性" >> $outfil
echo "pg /etc/inetd.conf |grep -v '^#' "  >> $outfil
cat /etc/inetd.conf |grep -v '^#'   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-2 檢視提供之系統服務是否適當"  >> $outfil
echo "==================================" >> $outfil
echo "6.2.1檢查/etc/rc.tcpip">> $outfil
echo "/etc/rc.tcpip |grep -v '^#'| grep 'start /' " >> $outfil
cat /etc/rc.tcpip |grep -v '^#'| grep 'start /' >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "6.2.2檢查/etc/inittab" >> $outfil 
echo 'cat /etc/inittab |grep -v "^:" '  >> $outfil
cat /etc/inittab | grep -v "^:"   >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "6.2.3檢查/rc.net" >> $outfil
echo "cat /etc/rc.net|grep -v '^#'" >> $outfil
cat /etc/rc.net|grep -v '^#' >> $outfil
echo "----------------------------------" >> $outfil
echo "6.2.4 檢查目前已開啟服務" >> $outfil
echo "lssrc -a|grep  active" >> $outfil
lssrc -a |grep active >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "7-1 確認目前是否已更新至修補程式之最適版本" >> $outfil
echo "==================================" >> $outfil
echo "修補至最適版本"   >> $outfil
echo "目前版本如下"   >> $outfil
oslevel -s >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "8-1 確認是否執行系統弱點掃描。 "  >> $outfil
echo "==================================" >> $outfil
echo "資安科已執行弱點掃描"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "9-1 確認主機實體之鑰匙已妥善保管、使用"  >> $outfil
echo "==================================" >> $outfil
echo "主機實體置於機櫃中,機櫃之鑰匙放置機房並設簿登記管制"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "9-2 確認是否裝置燒錄器及可攜式外接儲存設備"  >> $outfil
echo "==================================" >> $outfil
#echo "安裝軟體、開申請單核准後進機房使用"  >> $outfil
echo "未安裝燒錄器"  >> $outfil
echo "未安裝可攜式外接儲存設備"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "註：無法執行需述明理由"  >> $outfil
echo "==================================" >> $outfil
echo "經　　　辦："  >> $outfil
echo "" >> $outfil
echo "副　科　長："  >> $outfil
echo "" >> $outfil
echo "科　　　長："  >> $outfil
echo "" >> $outfil


#ftp -inv < logincfg

