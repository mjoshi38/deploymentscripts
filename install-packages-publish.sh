for i in `cat publish-ip.txt`
do
for j in `cat packages.txt`
do
      ./package-upload.sh "" "" $i 4503 $j
      sleep 30
done    
done

