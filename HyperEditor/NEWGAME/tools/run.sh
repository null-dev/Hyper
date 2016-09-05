echo "Doing magic!"
cd ..
mkdir -p tmpcmp
cp -r * tmpcmp/
cd tmpcmp
for checkx in *.t
do
   tools/tprologc "$checkx"
done
