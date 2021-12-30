#!/bin/bash
bash startserver.sh 2>&1 > startserver.out

mypid=$!

# keep a count how many times the word EULA appears in the output
# of the server
count=0


while read -r myline
do
	# check if line contains the word EULA
	if [[ $myline == *"EULA"* ]]
	then
		
		count=$((count+1))
		echo "EULA Complaint $count"
		
		# if the count is greater than 3, kill the server
		if [ $count -eq 2 ]
		then
			echo "Killing server"
			kill -9 $mypid
			exit 0
		fi
	fi
done < <(tail -1000f startserver.out)