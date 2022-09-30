#!/bin/bash

export LC_ALL=C

src_dir=$LOCAL_HOME/data/IEMOCAP
trans=$src_dir/emo_name_trans1.txt
output_dir=iemo

local_dir=data/local/$output_dir
data_dir=data/$output_dir

mkdir -p $local_dir
mkdir -p $data_dir

awk '{split($2, a, "."); print a[1]}' $trans > $local_dir/utts

awk '{print $1 " /disk/scratch3/zzhao/data/IEMOCAP/Data/" $1 ".wav" }' $local_dir/utts | sort > $data_dir/wav.scp

awk '{split($2, a, "."); $1=$2=""; print a[1] toupper($0)}' $trans | sort > $data_dir/text

awk '{split($2, a, ".");  split(a[1], b, "_"); print a[1] " " b[1]}' $trans | sort > $data_dir/utt2spk

./utils/utt2spk_to_spk2utt.pl $data_dir/utt2spk > $data_dir/spk2utt

steps/make_mfcc.sh --cmd run.pl --nj 10 data/iemo exp/make_mfcc/iemo mfcc
steps/compute_cmvn_stats.sh data/iemo exp/make_mfcc/iemo mfcc


