
for one_folder in $(ls -vd */);do
# remove last /
one_folder=${one_folder%*/}
cd $one_folder
echo "in folder: ${one_folder}"
if [ ! -f entry.json ]; then
  echo "entry.json not found"
  cd ..
  continue
fi
part_name=$(cat entry.json | jq -r '.page_data.part')
video_name="${one_folder}-${part_name}.mp4"
echo "file name: ${video_name}"

if [ ! -d 80 ]; then
  echo "no 80 folder"
  cd ..
  continue
fi
cd 80
file_count=$(find . -name '*.mp4' | wc -l)
if [[ $file_count -gt 0 ]]; then
    echo "mp4 exist"
    cd ../..
    continue
fi
if [ ! -f video.m4s ]; then
  echo "video.m4s not found"
  cd ../..
  continue
fi
echo "doing ffmpeg"
ffmpeg -i video.m4s -i audio.m4s -codec copy "${video_name}" >/dev/null 2>&1
echo "done ffmpeg"
cd ../..
done
