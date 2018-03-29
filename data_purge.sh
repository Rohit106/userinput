#!/bin/bash  


# define variable
TODAY=`date '+%d_%m_%Y_%H%M%S'`
BASEDIR="/usr/local/Ana_Apps/"
BACKUPDIRNAME=Backup
BACKUPBASEDIR="$BASEDIR$BACKUPDIRNAME"
BACKUPDIR="$BACKUPBASEDIR/$TODAY"

VAR1="$1"
OLDDAYSDATA=$2

echo ${VAR1[@]}

MYSQL_USER="xxxx"
MYSQL_PASS="xxxx"
MYSQL_DB="xxxxx"
MYSQL_TABLE="xxxx"
#MYSQL_INTERVEL="$1"

echo "creating backup base directory"
`/bin/mkdir -p $BACKUPDIR`

/usr/bin/mysql --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB -e "SELECT * FROM $MYSQL_TABLE where datetime < DATE((now() - interval $OLDDAYSDATA day)) INTO OUTFILE '/var/lib/mysql-files/$TODAY.csv' FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"

if [ $? -eq 0 ]; then
    echo "Backup completed"
    mv /var/lib/mysql-files/$TODAY.csv $BACKUPDIR
else
    echo " Exit due to Mysql backup failed "
    exit 0 ;
fi

#SQL="delete from $MYSQL_TABLE where datetime < DATE((now() - interval $OLDDAYSDATA day));"
#echo $SQL | /usr/bin/mysql --user=$MYSQL_USER --password=$MYSQL_PASS $MYSQL_DB

IFS=','; 
for i in `echo "$VAR1"`;
   do echo $'\n\n'"AppName:" $i;
   allappspath="$BASEDIR$i/data"
   echo "_____________ Storage will be created in $BACKUPDIR/$i/data ________________ " ;

   for d in $allappspath/*/ ; do
      dir=${d%*/}
      subDirectory=${dir##*/} 
      echo "Moving data from directory "$allappspath/$subDirectory" To "$BACKUPDIR/$i/data/$subDirectory
      `/bin/mkdir -p $BACKUPDIR/$i/data/$subDirectory`	

      find $allappspath/$subDirectory -mindepth 1 -type d -name "*[0-9]*" -mtime "+$OLDDAYSDATA" -exec mv -v {} "$BACKUPDIR/$i/data/$subDirectory" \;
      echo "Backup is copied to $BACKUPDIR/$i/data/$subDirectory"
      sleep 5
   done

done

echo "compress directory $BACKUPDIR as tar.gz"
cd "$BACKUPBASEDIR"
tar -cvzf $TODAY.tar.gz -P $BACKUPDIR >> $BACKUPBASEDIR/tar.gz.log
echo "Data compress successfully"

exit 0;
