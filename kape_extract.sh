#!/bin/bash
file1="$1"
file2="$2"
file3="$3"

while IFS="\n" read -r line 
do
  #echo $line
  line="${line/"."/"\."}"
  

  extract="$(grep -Eio ".*A[C.][.],.*\\\\(system32|syswow64|windows)\\\\$line" $file2 )"
  rmstr="$(echo $extract | grep -Evi "\\\\winsxs\\\\$line$"| grep -Evi "\.exe\.")"

  echo $rmstr
  time="$(echo "$rmstr" | grep -Eo "^[0-9/]{10},[0-9:]{8},")"
  proc="$(echo "$rmstr" | grep -Eo "[A-Za-z0-9]+.[A-Za-z0-9]{2,3}$" | sed 's/.*/\L&/g')"
  time_array+=($time)
  proc_array+=($proc)
  
  for i in "${!time_array[@]}"
  do
	  echo "${time_array[$i]}${proc_array[$i]},file access" | tee -a $file3


  done
  
  time_array=()
  proc_array=()



  extract="$(grep -Eio ".*AppCompatCache.*\\\\$line" $file2 )"
  
  time="$(echo "$extract" | grep -Eo "^[0-9/]{10},[0-9:]{8},")"
  proc="$(echo "$extract" | grep -Eo "[A-Za-z0-9]+.[A-Za-z0-9]{2,3}$" | sed 's/.*/\L&/g')"
  time_array+=($time)
  proc_array+=($proc)
  
  for i in "${!time_array[@]}"
  do
          echo "${time_array[$i]}${proc_array[$i]},shimcache" | tee -a $file3

  done
  
  time_array=()
  proc_array=()

done < "$file1"
