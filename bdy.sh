
# 视频分割点
all_spliter=$(grep '#EXT-X-BYTERANGE' .*.m3u8 |awk -F':' '{print $2}')
# 视频文件统计
ts_count=$(ls ts_*|wc -l)
# 视频文件索引
ts_index=-1
# 视频文件名
ts_file=ts_$ts_index
# 生成文件索引
counter=1

for index_spliter in $all_spliter;do
  byte_skip=$(echo -e $index_spliter |awk -F'@' '{print $2}')
  byte_count=$(echo -e $index_spliter |awk -F'@' '{print $1}')
  # 0开始是新的视频文件开始
  if [[ $byte_skip -eq 0 ]] ;then
    ts_index=$((ts_index + 1))
  fi
  ts_file=ts_${ts_index}
  output_file=${counter}.ts
  if [[ $byte_skip -eq 0 ]] ;then
    dd_cmd="dd if=$ts_file  bs=$byte_count count=1 > $output_file"
  else
    dd_cmd="dd if=$ts_file bs=$byte_skip skip=1 | dd bs=$byte_count count=1 > $output_file"
  fi
  echo "file:$ts_file skip:$byte_skip count:$byte_count output_file:$output_file"
  echo "  cmd: $dd_cmd"
  echo "  ffmpeg: ffmpeg -i ${counter}.ts -c copy ${counter}.mp4"

  eval "$dd_cmd"
  ffmpeg -i ${counter}.ts -c copy ${counter}.mp4
  # 检查文件问题, 问题会导致合成出错，没问题写入列表文件
  file_error=$(ffmpeg -v error -i ${counter}.mp4 -f null - 2>&1)
  if [ -z "$file_error" ] ;then
    echo "file ${counter}.mp4" >>ts_list.txt
  fi

  counter=$((counter + 1))
done

ffmpeg -f concat -i ts_list.txt -c copy $(ls .*.m3u8).mp4