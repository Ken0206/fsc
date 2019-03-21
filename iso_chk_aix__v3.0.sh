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
echo "#�� �� #" >> $outfil
echo "#########" >> $outfil
echo " " >> $outfil
echo " " >> $outfil
echo  `hostname` "AIX�t�αj���ˮ֪����" >> $outfil
echo " "  >> $outfil
echo " " >> $outfil
echo "1. �����n���e���W�����n�t�θ�T" >> $outfil
echo "1-1 �n���e����welcome message�O�_�t���t�θ�T" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/security/login.cfg" >> $outfil
echo " �T�{�n���e���T�� herald= Unauthorized use of this system is prohibited." >> $outfil
echo " �T�{ logindelay=5 " >> $outfil
cat /etc/security/login.cfg|grep -v '*'|head -10 >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2. �ϥΪ̪��w���޲z" >> $outfil
echo "2-1 �T�{�K�X�~�誺�]�w�O�_�̷Ӥ��q�F���]�w" >> $outfil
echo "==================================" >> $outfil
echo " cat /etc/security/user |grep -v '^*' "  >> $outfil
cat /etc/security/user|grep -v "^*" >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-2 �T�{root�b�����޲z�O�_�A��" >> $outfil
echo "==================================" >> $outfil
echo "2.2.1 �T�{root�b���w�g�Ѩt�κ޲z��^������" >> $outfil
echo "root�b���w�Ѩt�κ޲z��^������" >> $outfil
echo "----------------------------------" >> $outfil
echo "2.2.2 �T�{/etc/passwd, root�� uid �M gid " >> $outfil
echo "cat /etc/passwd|grep '0:0' "  >> $outfil
cat /etc/passwd |grep '0:0'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.3 �C�X/etc/passwd��,uid��gid��0���Ҧ��ϥΪ�,���ˬd�O�_�A��" >> $outfil
echo "cat /etc/passwd|grep '0:0' "  >> $outfil
cat /etc/passwd |grep '0:0'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.4 �ˬdroot �� rlogin=false ����ݪ����n�J " >> $outfil
echo "cat /etc/security/user " >> $outfil
cat /etc/security/user |egrep "root|rlogin" |grep -v "^*" |head -3 >> $outfil
echo "lsuser -a rlogin root " >> $outfil
lsuser -a rlogin root >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "2.2.5 �ˬdroot �O�_�����w�w���j�M���|" >> $outfil
echo 'echo $PATH '  >> $outfil
echo  $PATH >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-3 �T�{��L�t�ιw�]�b���O�_���n�s�b" >> $outfil
echo "==================================" >> $outfil
echo "2.3.1 �ˬd�b���C��A�O�_�d���p guest, uucp, nuucp �M lpd �b������w" >> $outfil
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
echo "2.3.2 �C�ܽT�{�t�ӨϥΤ��b��"  >> $outfil
echo "�L�t�ӨϥΤ��b��"  >> $outfil
#echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 > 200 {print \$1}'|grep -v nobody|grep -v ipsec" >> $outfil
#cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 > 200 {print $1}'|grep -v nobody|grep -v ipsec >> $outfil
echo "----------------------------------" >> $outfil
echo "2.3.3 �C�ܩҦ��t�ιw�]�b�� "  >> $outfil
echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 <= 300 {print \$1}'" >> $outfil
cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 <= 300 {print $1}' >> $outfil
echo "----------------------------------" >> $outfil
echo "2.3.4 �ˬd/etc/passwd "  >> $outfil
echo "cat /etc/passwd "  >> $outfil
cat /etc/passwd |grep -v '^#'  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "  " >> $outfil

echo "2-4 �T�{�j���ϥΪ̥��@����ʧ@�W�L�@�w�ɶ��ɡA���H�j���n�X�C" >> $outfil
echo "==================================" >> $outfil
echo "�ˬd/etc/profile�O�_�]�� TMOUT �Ѽ� 900=15 minutes " >> $outfil
echo "cat /etc/profile|grep TMOUT"  >> $outfil
cat /etc/profile |grep TMOUT >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "2-5 �T�{�ϥΪ̤��i�ܧ�/etc/profile�]�w��" >> $outfil
#echo "2-5 �T�{�u���t�κ޲z�̥i�ܧ�/etc/profile�]�w��" >> $outfil
echo "==================================" >> $outfil
echo " �T�{ /etc/profile �ϥΪ̵L�ܧ��v��"  >> $outfil
echo "ls -l /etc/profile "  >> $outfil
ls -l /etc/profile  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-6 �T�{�t�ιw�]�ϥΪ̱b����umask�Ȭ�027" >> $outfil
echo "==================================" >> $outfil
echo "�T�{�t�ιw�]�ϥΪ̱b�� umask �ȡA�@��ϥΪ̱b���i��022 " >> $outfil
echo "cat /etc/passwd|awk 'FS=":" {print \$1,\$3}'|awk '\$2 <= 300 {system("lsuser -a -f umask " $1)}'" >> $outfil
cat /etc/passwd|awk 'FS=":" {print $1,$3}'|awk '$2 <= 300 {system("lsuser -a -f umask " $1)}' >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-7 �T�{�ϥΪ̥N�X���K�X��" >> $outfil
echo "==================================" >> $outfil
echo "�ˬd�ϥΪ̥N�X���K�X��" >> $outfil
 /src/chkau/passwd_check.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-8 �T�{�����ɬO�_�A��H" >> $outfil
echo "==================================" >> $outfil
echo "�ˬd���ε{���Ҧb���|�U�������ɬO�_�A�� " >> $outfil
    /src/chkau/hidden_files.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "2-9 �T�{NoUser���ɮסH" >> $outfil
echo "==================================" >> $outfil
echo "�ˬd���ε{���Ҧb���|�UNoUser���ɮ׬O�_�A�� " >> $outfil
    /src/chkau/nouser_files.sh >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "3-1 �T�{/etc/hosts.equiv�B rhosts�B.netrc�s�b�����n��" >> $outfil
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

echo "3-2 �T�{����root�b���u���Console�n�J"  >> $outfil
echo "==================================" >> $outfil
echo "lsuser -a -f login rlogin root "  >> $outfil
lsuser -a -f login rlogin root  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-1 �T�{�t�Τ��]�֥\��w�g�Ұ�"  >> $outfil
echo "==================================" >> $outfil
echo "4.1.1���}�ҽ]�ּҦ� binmode=on �� streammode=on ">> $outfil
echo "cat  /etc/security/audit/config|head -4  "  >> $outfil
cat /etc/security/audit/config|head -4  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "4.1.2 �T�O�S���v���b���Ҥ޵o�ƥ�Ҧ��O���A�p Users: root=general " >> $outfil
echo "cat  /etc/security/audit/config|grep root" >> $outfil
cat  /etc/security/audit/config|grep root  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-2 �T�{�t�έ��n�ؿ��Ϊ���]�֬����w�Ұ�"  >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/security/audit/objects "  >> $outfil
cat /etc/security/audit/objects >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-3 �T�{�]�ֳ]�w���v��"  >> $outfil
echo "==================================" >> $outfil
echo "���T�O/etc/security/audit �ؿ��U�Ҧ��]�ֳ]�w�ɶȦ�root �i�s��" >> $outfil
echo "ls -lR /etc/security/audit " >> $outfil
chmod 600 /aulog/bin1
chmod 600 /aulog/bin2
ls -lR /etc/security/audit  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "4-4 �T�{�t�ν]��log���v��"  >> $outfil
echo "==================================" >> $outfil
echo "ls -ld /aulog  "  >> $outfil
ls -ld /aulog   >> $outfil
echo "----------------------------------" >> $outfil
echo "ls -l /aulog  "  >> $outfil
ls -l /aulog   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "4-5 �T�{�t�ν]�֤�x�۰ʶ}�ҳ]�w"  >> $outfil
echo "==================================" >> $outfil
echo "cat /etc/inittab |grep audit " >> $outfil
cat /etc/inittab |grep audit  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "5-1 �T�{���|���]�w�����ܼ�"  >> $outfil
echo "==================================" >> $outfil
echo 'su - root "-c env| grep PATH "'  >> $outfil
su - root "-c env| grep PATH"   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "5-2 �T�{cron�Mat Jobs�]�w���A���" >> $outfil
echo "==================================" >> $outfil
echo "5.2.1�T�{cron.allow��at.allow �u��root�W�C�䤤" >> $outfil
echo "cat /var/adm/cron/cron.allow "  >> $outfil
cat /var/adm/cron/cron.allow  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "cat /var/adm/cron/at.allow "  >> $outfil
cat /var/adm/cron/at.allow  >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "5.2.2�˵�var/adm/cron�O�_��cron.deny��at.deny���ɮ� " >> $outfil
echo "ls -l /var/adm/cron|grep deny" >> $outfil
ls -l /var/adm/cron|grep deny >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "  " >> $outfil


echo "5-3 �T�{Cron control file (/var/spool/cron/crontabs/*)�O�_�g�A��O�@" >> $outfil
echo "==================================" >> $outfil
echo "5.3.1 �ˬd���ɮ��v��" >> $outfil
echo "ls -l /var/spool/cron/crontabs/ " >> $outfil
ls -l /var/spool/cron/crontabs/ >> $outfil
echo "----------------------------------" >> $outfil
echo "5.3.2 �Hcronadm cron -l �M�d�Ҧ���cron job �O�_�A��" >> $outfil
echo "cronadm cron -l|grep -v '^#' " >> $outfil
cronadm cron -l|grep -v '^#'  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-1 ���������n���t�ΪA��"  >> $outfil
echo "==================================" >> $outfil
echo "6.1.1 �T�{�}�Ҫ��q�T���TCP/IP�A�ȾA���" >> $outfil
echo "pg /etc/inetd.conf |grep -v '^#' "  >> $outfil
cat /etc/inetd.conf |grep -v '^#'   >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "6-2 �˵����Ѥ��t�ΪA�ȬO�_�A��"  >> $outfil
echo "==================================" >> $outfil
echo "6.2.1�ˬd/etc/rc.tcpip">> $outfil
echo "/etc/rc.tcpip |grep -v '^#'| grep 'start /' " >> $outfil
cat /etc/rc.tcpip |grep -v '^#'| grep 'start /' >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "6.2.2�ˬd/etc/inittab" >> $outfil 
echo 'cat /etc/inittab |grep -v "^:" '  >> $outfil
cat /etc/inittab | grep -v "^:"   >> $outfil
echo "---------   ----------  ----------- " >> $outfil
echo "6.2.3�ˬd/rc.net" >> $outfil
echo "cat /etc/rc.net|grep -v '^#'" >> $outfil
cat /etc/rc.net|grep -v '^#' >> $outfil
echo "----------------------------------" >> $outfil
echo "6.2.4 �ˬd�ثe�w�}�ҪA��" >> $outfil
echo "lssrc -a|grep  active" >> $outfil
lssrc -a |grep active >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "7-1 �T�{�ثe�O�_�w��s�ܭ׸ɵ{�����̾A����" >> $outfil
echo "==================================" >> $outfil
echo "�׸ɦܳ̾A����"   >> $outfil
echo "�ثe�����p�U"   >> $outfil
oslevel -s >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "8-1 �T�{�O�_����t�ήz�I���y�C "  >> $outfil
echo "==================================" >> $outfil
echo "��w��w����z�I���y"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil


echo "9-1 �T�{�D�����餧�_�ͤw�����O�ޡB�ϥ�"  >> $outfil
echo "==================================" >> $outfil
echo "�D������m����d��,���d���_�ͩ�m���Шó]ï�n�O�ި�"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil

echo "9-2 �T�{�O�_�˸m�N�����Υi�⦡�~���x�s�]��"  >> $outfil
echo "==================================" >> $outfil
#echo "�w�˳n��B�}�ӽг�֭��i���Шϥ�"  >> $outfil
echo "���w�˿N����"  >> $outfil
echo "���w�˥i�⦡�~���x�s�]��"  >> $outfil
echo "----------------------------------" >> $outfil
echo "  " >> $outfil
echo "���G�L�k����ݭz���z��"  >> $outfil
echo "==================================" >> $outfil
echo "�g�@�@�@��G"  >> $outfil
echo "" >> $outfil
echo "�ơ@��@���G"  >> $outfil
echo "" >> $outfil
echo "��@�@�@���G"  >> $outfil
echo "" >> $outfil


#ftp -inv < logincfg

