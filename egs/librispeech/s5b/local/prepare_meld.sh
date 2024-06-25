#!/bin/bash

export LC_ALL=C

src_dir=$LOCAL_HOME/data/MELD
output_dir=meld
utt_files=$src_dir/MELD.txt

local_dir=data/local/$output_dir
data_dir=data/$output_dir

mkdir -p $local_dir
mkdir -p $data_dir

awk '{split($0, a, ","); print "train-" a[1]}' $src_dir/train.txt > $local_dir/train_utts
awk '{split($0, a, ","); print "dev-" a[1]}' $src_dir/dev.txt > $local_dir/dev_utts
awk '{split($0, a, ","); print "test-" a[1]}' $src_dir/test.txt > $local_dir/test_utts

cat $utt_files | awk -F, '{print $1}' | sort > $local_dir/utts


awk '{split($0, a, ","); split(a[1], b, "-"); print a[1] " sox /disk/scratch3/zzhao/data/MELD/" b[1]"_audio/" b[2] ".wav -c 1 -t wav -r 16000 - |" }' $local_dir/utts | sort > $data_dir/wav.scp

awk '{split($0, a, ","); print "train-" a[1] " " toupper(a[2])}' $src_dir/train.txt| sort > $local_dir/train_text
awk '{split($0, a, ","); print "dev-" a[1] " " toupper(a[2])}' $src_dir/dev.txt| sort > $local_dir/dev_text
awk '{split($0, a, ","); print "test-" a[1] " " toupper(a[2])}' $src_dir/test.txt| sort > $local_dir/test_text


(cat $local_dir/train_text; cat $local_dir/dev_text; cat $local_dir/test_text) | sort > $data_dir/text

(awk '{split($0, a, ","); print "train-" a[1] " train-" a[1]}' $src_dir/train.txt; awk '{split($0, a, ","); print "dev-" a[1] " dev-" a[1]}' $src_dir/dev.txt; awk '{split($0, a, ","); print "test-" a[1] " test-" a[1]}' $src_dir/test.txt ) | sort > $data_dir/utt2spk

./utils/utt2spk_to_spk2utt.pl $data_dir/utt2spk > $data_dir/spk2utt

./utils/fix_data_dir.sh $data_dir


