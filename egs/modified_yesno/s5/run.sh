#!/usr/bin/env bash

train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

#if [ ! -d waves_yesno ]; then
  #wget http://www.openslr.org/resources/1/waves_yesno.tar.gz || exit 1;
  ## was:
  ## wget http://sourceforge.net/projects/kaldi/files/waves_yesno.tar.gz || exit 1;
  #tar -xvzf waves_yesno.tar.gz || exit 1;
#fi

train_set=train_3gram
test_set_suffix="yyn ynn 3gram sam_yyn sam_ynn sam_3gram sam_yyn_noise sam_ynn_noise sam_3gram_noise"
ngauss=10

#rm -rf exp mfcc

# Data preparation

#local/prepare_data.py --dir /disk/scratch4/zzhao/Datasets/modified_yesno
#for x in train_yyn dev_yyn test_yyn train_ynn dev_ynn test_ynn train_3gram dev_3gram test_3gram; do
    #sort data/$x/wav.scp > data/$x/wav.scp.sorted
    #sort data/$x/text > data/$x/text.sorted
    #sort data/$x/utt2spk > data/$x/utt2spk.sorted
    #mv data/$x/wav.scp.sorted data/$x/wav.scp
    #mv data/$x/text.sorted data/$x/text
    #mv data/$x/utt2spk.sorted data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done
#local/prepare_sam_data.py --dir /disk/scratch4/zzhao/Datasets/modified_yesno
#for x in test_sam_yyn test_sam_ynn test_sam_3gram; do
    #sort data/$x/wav.scp > data/$x/wav.scp.sorted
    #sort data/$x/text > data/$x/text.sorted
    #sort data/$x/utt2spk > data/$x/utt2spk.sorted
    #mv data/$x/wav.scp.sorted data/$x/wav.scp
    #mv data/$x/text.sorted data/$x/text
    #mv data/$x/utt2spk.sorted data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done
#local/prepare_sam_noise_data.py --dir /disk/scratch4/zzhao/Datasets/modified_yesno
#for x in test_sam_yyn_noise test_sam_ynn_noise test_sam_3gram_noise; do
    #sort data/$x/wav.scp > data/$x/wav.scp.sorted
    #sort data/$x/text > data/$x/text.sorted
    #sort data/$x/utt2spk > data/$x/utt2spk.sorted
    #mv data/$x/wav.scp.sorted data/$x/wav.scp
    #mv data/$x/text.sorted data/$x/text
    #mv data/$x/utt2spk.sorted data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done

#local/prepare_dict.sh
#utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang
#local/prepare_lm.sh

# Feature extraction
#for x in train_yyn dev_yyn test_yyn train_ynn dev_ynn test_ynn train_3gram dev_3gram test_3gram; do 
 #steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 #steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 #utils/fix_data_dir.sh data/$x
#done
#for x in test_sam_yyn test_sam_ynn test_sam_3gram; do 
 #steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 #steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 #utils/fix_data_dir.sh data/$x
#done
#for x in test_sam_yyn_noise test_sam_ynn_noise test_sam_3gram_noise; do 
 #steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 #steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 #utils/fix_data_dir.sh data/$x
#done

# Mono training
#steps/train_mono.sh --nj 1 --cmd "$train_cmd" \
  #--totgauss ${ngauss}\
  #data/${train_set} data/lang exp/mono_${train_set}_${ngauss}
  
 #Graph compilation and decoding with correct G.fst
for x in ${test_set_suffix}; do
    utils/mkgraph.sh data/lang_test_${x} exp/mono_${train_set}_${ngauss} exp/mono_${train_set}_${ngauss}/graph_tgpr_${x}
done

for x in ${test_set_suffix}; do
    steps/decode.sh --nj 1 --cmd "$decode_cmd" \
        exp/mono_${train_set}_${ngauss}/graph_tgpr_${x} data/test_${x} exp/mono_${train_set}_${ngauss}/decode_test_${x}
done

# with default G.fst
utils/mkgraph.sh data/lang_test_tg exp/mono_${train_set}_${ngauss} exp/mono_${train_set}_${ngauss}/graph_tgpr_tg
for x in ${test_set_suffix}; do
    steps/decode.sh --nj 1 --cmd "$decode_cmd" \
        exp/mono_${train_set}_${ngauss}/graph_tgpr_tg data/test_${x} exp/mono_${train_set}_${ngauss}/decode_test_tg_${x}
done

#for x in exp/mono_${train_set}_${ngauss}/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
