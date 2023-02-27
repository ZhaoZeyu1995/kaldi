#!/bin/bash
#

# This script aligns the data using the GMM-HMM model for the asr coursework data.

./utils/utt2spk_to_spk2utt.pl data/asr_data/utt2spk > data/asr_data/spk2utt

./steps/make_mfcc.sh --nj 10 --cmd run.pl data/asr_data
./steps/compute_cmvn_stats.sh data/asr_data

[[ -d exp/mono0a_ali_asr_data ]] && rm -r exp/mono0a_ali_asr_data
./steps/align_si.sh --nj 10 --cmd run.pl data/asr_data data/lang_nosp exp/mono0a exp/mono0a_ali_asr_data


