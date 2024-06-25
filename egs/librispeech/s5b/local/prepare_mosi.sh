#!/bin/bash

export LC_ALL=C

src_dir=$LOCAL_HOME/data/MOSI
trans=$src_dir/name_trans.txt
new_trans=$src_dir/corrected_uttids
output_dir=mosi

local_dir=data/local/$output_dir
data_dir=data/$output_dir

mkdir -p $local_dir
mkdir -p $data_dir

awk '{print $0}' $new_trans | sort > $local_dir/utts

awk '{split($0, a, ","); print a[1] " sox /disk/scratch3/zzhao/data/MOSI/Audio/" a[1] ".wav -c 1 -t wav - |" }' $local_dir/utts | sort > $data_dir/wav.scp

awk '{split($0, a, ","); print a[1] " " toupper(a[2])}' $trans | sort > $data_dir/text

awk '{split($0, a, ","); print a[1] " " a[1]}' $trans | sort > $data_dir/utt2spk

./utils/utt2spk_to_spk2utt.pl $data_dir/utt2spk > $data_dir/spk2utt

./utils/fix_data_dir.sh $data_dir


