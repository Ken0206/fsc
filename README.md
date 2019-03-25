### 檔案清單︰
```
01. README.md                          本檔案
02. hidden_files.sh                    隱藏檔檢查
03. exclude_hidden_files               隱藏檔檢查-排除清單
04. passwd_check.sh                    密碼檢查
05. nouser_files.sh                    nouser 檔案檢查
06. user_files.sh                      搜尋特定帳號所屬檔案清單 (有互動選單)
07. export_env                         共同設定
08. check_permission_and_md5.sh        帳號對程式及資料檔案相關權限之檢查 (有互動選單)
09. check_permission_and_md5_direct.sh 同上，沒有互動選單，直接輸出報告
10. 5 個 check 檔
> iso_chk_aix__v3.0.sh
> iso_chk_linux_rhel6_3.0.sh
> iso_chk_linux_rhel7_3.0.sh
> iso_chk_linux_suse11_3.0.sh
> iso_chk_linux_suse12_3.0.sh
```
---
### script 共同特性︰
```
1. 必須以 root 權限執行
2. script 必須位於 /src/chkau/ 執行
3. Linux 和 AIX 皆可執行
4. 每次執行都會刪除 /src/chkau/report/ 下 60 天前的檔案
```
---
### 1. hidden_files.sh 隱藏檔檢查
```
基準檔1：  /src/chkau/baseLine/$(hostname)_hidden.txt
基準檔2：  /src/chkau/baseLine/$(hostname)_hidden.txt.d
第一次執行，沒有基準檔，或刪除任一基準檔，
將當時找到的所有隱藏檔自動產生為基準檔。

每次執行產生隱藏檔清單，存於︰
/src/chkau/report/$(hostname)_hidden_YYYYmmdd_HHMMSS.txt
   
執行報告︰  /src/chkau/report/$(hostname)_hidden_Report.txt
```   
---
### 2. exclude_hidden_files 隱藏檔檢查-排除檢查清單
```
此檔沒有內容則不排除資料
此檔可以設定多行，一行是一個排除條件
   
如果要排除，建議設定全路徑如下︰
^/webmail/mbase
開頭是 /webmail/mbase 的排除
   
如果設定︰
/webmail/mbase
只要符合 */webmail/mbase* 都會排除
```
---
### 3. passwd_check.sh 密碼檢查
```
執行報告︰  /src/chkau/report/$(hostname)_passwd_check_Report.txt
```
---
### 4. nouser_files.sh 是 nouser 檔案檢查
```
基準檔1：  /src/chkau/baseLine/$(hostname)_nouser.txt
基準檔2：  /src/chkau/baseLine/$(hostname)_nouser.txt.d
第一次執行，沒有基準檔，或刪除任一基準檔，
將當時找到的所有 nouser 檔自動產生為基準檔。

當次搜尋所有 nouser 檔案清單︰
/src/chkau/report/$(hostname)_nouser_YYYYmmdd_HHMMSS.txt
   
執行報告︰  /src/chkau/report/$(hostname)_nouser_Report.txt
```
---
### 5. user_files.sh 搜尋特定帳號所屬檔案清單此 (有互動選單)
```
執行報告︰  /src/chkau/report/$(hostname)_files_list_Report.txt
執行報告檔如果大於 1024000，自動刪除 1000 行以前的資料

每次執行搜尋帳號產生檔清單，存於︰
/src/chkau/report/$(hostname)_files_list_${user_name}_YYYYmmdd_HHMMSS.txt

如果有刪除 user file 將備份存於 /source/backupUserFiles/
檔案名稱如︰ YYYYmmdd_HHMMSS_userName.tar.gz
每執行本 script 會刪除7天前的備份檔
```
---
### 6. check_permission_and_md5.sh 帳號對程式及資料檔案相關權限之檢查 (有互動選單)
```
   執行報告︰  /src/chkau/report/ACCESS_report_$(hostname)_YYYYmmdd.txt
```
