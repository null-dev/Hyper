cd $1
mogrify -background white -alpha remove -format jpg *.png
mkdir -p TRANSPARENT
mv *.png TRANSPARENT
echo "Conversion OK!"
