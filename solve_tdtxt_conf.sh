#!/bin/sh
#set -x

WORKDIR=$1
cd $WORKDIR
mkdir -p Backups

#Group conflicts
cat todo*.txt | sort -u | tee todo.txt

#Backup done.txt
cp done.txt Backups/$(date '+%Y-%m-%d-%H%M')_done.txt

#Group done.txt conflicts
cat done*.txt | sort -u | tee done.txt

#Cleanup done.txt for x markers and save to a temp file
cat done.txt | sed "s/x //g" > procdone.out

#Remove the collected done tasks from the todo.txt and save results to a tempfile
grep -Fvxf procdone.out todo.txt > todo.tmp.txt

#Backup todo.txt
mv todo.txt Backups/$(date '+%Y-%m-%d-%H%M')_todo.txt

#Save processed todo.txt and remove tempfile
mv todo.tmp.txt todo.txt

#Restore backup if something went wrong and files are removed
if [ ! -s todo.txt ];
then
  for i in $(ls -at Backups/*todo.txt);
  do
    if [ -s $i ];
    then
      cp $i todo.txt
      break
    fi
  done
fi

if [ ! -s done.txt ];
then
  for i in $(ls -at Backups/*done.txt);
  do
    if [ -s $i ];
    then
      cp $i done.txt
      break
    fi
  done
fi

#Remove pseudo-duplicates
while read p; 
do 
	todo_line="$(echo $p | sed -E 's/([a-zA-Z]*:\+?[0-9]*(d|m|w|y)?(-?[0-9]*-[0-9]*)?)|((\+|#|\/)[a-zA-Z]*)|(\([A-Z]\))|([0-9]{4}-[0-9]{2}-[0-9]{2})//g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"; 
	cat todo.txt | grep "$todo_line" | sort -nr | head -n 1 >> todo.txt.new

done <todo.txt

#Backup conflicts
mv *sync-conflict* Backups/

#Save final results
mv todo.txt.new todo.txt

#Final cleanup
rm procdone.out

