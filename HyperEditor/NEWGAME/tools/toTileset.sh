echo "tileset converter based on original 4/8chan multiple image download by: nulldev"

function sedeasy {
  sed -e "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g"
}

for var in *.{jpg,jpeg}
do
    cat "/home/hc/Desktop/Software/OpenTuring/HyperEditor/NEWGAME/tools/tile_template.htf.txt" | sedeasy "%FILENAME%" "$var" > "./$var.htf.txt"
    echo "Processed: $var"
done
