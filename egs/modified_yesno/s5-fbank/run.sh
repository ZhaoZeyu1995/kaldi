#!/usr/bin/env bash

train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"

train_set=train_yyn
test_set_suffix="yyn ynn 3gram sam_yyn sam_ynn sam_3gram sam_yyn_noise sam_ynn_noise sam_3gram_noise"
ngauss=20

#rm -rf exp mfcc

# Data preparation

data_dir=/afs/inf.ed.ac.uk/user/s20/s2070789/Documents/Work/CSTR/lennoxtown/s3/data/modified_yesno

#local/prepare_data.py --dir $data_dir
#for x in train_yyn dev_yyn test_yyn train_ynn dev_ynn test_ynn train_3gram dev_3gram test_3gram; do
    #localdir=data/local/$x
    #mkdir -p $localdir
    #sort data/$x/wav.scp > $localdir/wav.scp
    #sort data/$x/text > $localdir/text
    #sort data/$x/utt2spk > $localdir/utt2spk
    #cp $localdir/wav.scp data/$x/wav.scp
    #cp $localdir/text data/$x/text
    #cp $localdir/utt2spk data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done
#local/prepare_sam_data.py --dir $data_dir
#for x in test_sam_yyn test_sam_ynn test_sam_3gram; do
    #localdir=data/local/$x
    #mkdir -p $localdir
    #sort data/$x/wav.scp > $localdir/wav.scp
    #sort data/$x/text > $localdir/text
    #sort data/$x/utt2spk > $localdir/utt2spk
    #cp $localdir/wav.scp data/$x/wav.scp
    #cp $localdir/text data/$x/text
    #cp $localdir/utt2spk data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done
#local/prepare_sam_noise_data.py --dir $data_dir
#for x in test_sam_yyn_noise test_sam_ynn_noise test_sam_3gram_noise; do
    #localdir=data/local/$x
    #mkdir -p $localdir
    #sort data/$x/wav.scp > $localdir/wav.scp
    #sort data/$x/text > $localdir/text
    #sort data/$x/utt2spk > $localdir/utt2spk
    #cp $localdir/wav.scp data/$x/wav.scp
    #cp $localdir/text data/$x/text
    #cp $localdir/utt2spk data/$x/utt2spk
    #utils/utt2spk_to_spk2utt.pl <data/$x/utt2spk > data/$x/spk2utt
#done

#local/prepare_dict.sh
#utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<SIL>" data/local/lang data/lang
#local/prepare_lm.sh

# Feature extraction
#for x in train_yyn dev_yyn test_yyn train_ynn dev_ynn test_ynn train_3gram dev_3gram test_3gram; do 
 #steps/make_fbank_pitch.sh --nj 1 data/$x exp/make_fbank/$x fbank
 #steps/compute_cmvn_stats.sh data/$x exp/make_fbank/$x fbank
 #utils/fix_data_dir.sh data/$x
#done
#for x in test_sam_yyn test_sam_ynn test_sam_3gram; do 
 #steps/make_fbank_pitch.sh --nj 1 data/$x exp/make_fbank/$x fbank
 #steps/compute_cmvn_stats.sh data/$x exp/make_fbank/$x fbank
 #utils/fix_data_dir.sh data/$x
#done
#for x in test_sam_yyn_noise test_sam_ynn_noise test_sam_3gram_noise; do 
 #steps/make_fbank_pitch.sh --nj 1 data/$x exp/make_fbank/$x fbank
 #steps/compute_cmvn_stats.sh data/$x exp/make_fbank/$x fbank
 #utils/fix_data_dir.sh data/$x
#done

# Mono training
steps/train_mono_wo_delta.sh --nj 1 --cmd "$train_cmd" \
  --totgauss ${ngauss}\
  data/${train_set} data/lang exp/mono_${train_set}_${ngauss}
  
 #Graph compilation and decoding with correct G.fst
for x in ${test_set_suffix}; do
    utils/mkgraph.sh data/lang_test_${x} exp/mono_${train_set}_${ngauss} exp/mono_${train_set}_${ngauss}/graph_tgpr_${x}
done

for x in ${test_set_suffix}; do
    steps/decode_wo_delta.sh --nj 1 --cmd "$decode_cmd" \
        exp/mono_${train_set}_${ngauss}/graph_tgpr_${x} data/test_${x} exp/mono_${train_set}_${ngauss}/decode_test_${x}
done

# with default G.fst
utils/mkgraph.sh data/lang_test_tg exp/mono_${train_set}_${ngauss} exp/mono_${train_set}_${ngauss}/graph_tgpr_tg
for x in ${test_set_suffix}; do
    steps/decode_wo_delta.sh --nj 1 --cmd "$decode_cmd" \
        exp/mono_${train_set}_${ngauss}/graph_tgpr_tg data/test_${x} exp/mono_${train_set}_${ngauss}/decode_test_tg_${x}
done

#for x in exp/mono_${train_set}_${ngauss}/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done
