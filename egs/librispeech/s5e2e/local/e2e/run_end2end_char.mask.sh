#!/usr/bin/env bash
# Copyright 2017    Hossein Hadian

# This top-level script demonstrates character-based end-to-end LF-MMI training
# (specifically single-stage flat-start LF-MMI models) on WSJ. It is exactly
# like "run_end2end_phone.sh" excpet it uses a trivial grapheme-based
# (i.e. character-based) lexicon and a stronger neural net (i.e. TDNN-LSTM)

set -euo pipefail


stage=0
trainset=train_960_wmask
. ./cmd.sh ## You'll want to change cmd.sh to something that will work
           ## on your system. This relates to the queue.

#wsj0=/ais/gobi2/speech/WSJ/csr_?_senn_d?
#wsj1=/ais/gobi2/speech/WSJ/csr_senn_d?

#wsj0=/mnt/matylda2/data/WSJ0
#wsj1=/mnt/matylda2/data/WSJ1

#wsj0=/data/corpora0/LDC93S6B
#wsj1=/data/corpora0/LDC94S13B

data=/disk/scratch3/zzhao/data/librispeech
lm_url=www.openslr.org/resources/11

. ./utils/parse_options.sh
. ./path.sh

# We use the suffix _nosp for the phoneme-based dictionary and
# lang directories (for consistency with run.sh) and the suffix
# _char for character-based dictionary and lang directories.

mprobs="0 0.1 0.15 0.2 0.25 0.3 0.35 0.4"
snrs="-10 -5 0 5 10 15 20"
test_sets="dev_clean dev_other test_clean test_other"
for m in $mprobs; do
    test_sets="$test_sets test_mask${m}"
done
for m in $mprobs; do
    for s in $snrs; do
        test_sets="$test_sets test_mask${m}_SNR${s}"
    done
done

echo "test_sets: $test_sets"

if [ $stage -le 0 ]; then
  # format the data as Kaldi data directories
  for part in dev-clean test-clean dev-other test-other train-clean-100 train-clean-360 train-other-500; do
    # use underscore-separated names in data directories.
    local/data_prep.sh $data/LibriSpeech/$part data/$(echo $part | sed s/-/_/g)
  done

  # download the LM resources
  local/download_lm.sh $lm_url data/local/lm
  local/prepare_dict.sh --stage 3 --nj 30 --cmd "$train_cmd" \
   data/local/lm data/local/lm data/local/dict_nosp

  #local/librispeech_prepare_char_dict.sh
  utils/prepare_lang.sh data/local/dict_char \
                        "<SPOKEN_NOISE>" data/local/lang_tmp_char data/lang_char
  local/format_lms.sh --src-dir data/lang_char data/local/lm

  utils/build_const_arpa_lm.sh data/local/lm/lm_tglarge.arpa.gz \
    data/lang_char data/lang_char_test_tglarge
  utils/build_const_arpa_lm.sh data/local/lm/lm_fglarge.arpa.gz \
    data/lang_char data/lang_char_test_fglarge
  echo "$0: Done preparing data & lang."
fi

if [ $stage -le 2 ]; then
  # make MFCC features for the test data. Only hires since it's flat-start.
    echo "$0: extracting MFCC features for the test sets"
    for x in $test_sets; do
      mv data/$x data/${x}_hires
      steps/make_mfcc.sh --cmd "$train_cmd" --nj 10 \
                         --mfcc-config conf/mfcc_hires.conf data/${x}_hires
      steps/compute_cmvn_stats.sh data/${x}_hires
    done
fi

if [ $stage -le 3 ]; then
    echo "$0: extracting MFCC features for the training data..."

    utils/data/get_utt2dur.sh data/$trainset  # necessary for the next command
    utils/data/perturb_speed_to_allowed_lengths.py 12 --speed-perturb false data/${trainset} data/${trainset}_spe2e_hires

    cat data/${trainset}_spe2e_hires/utt2dur | \
      awk '{print $1 " " substr($1,5)}' >data/${trainset}_spe2e_hires/utt2uniq
    utils/fix_data_dir.sh data/${trainset}_spe2e_hires
    steps/make_mfcc.sh --nj 10 --mfcc-config conf/mfcc_hires.conf \
                     --cmd "$train_cmd" data/${trainset}_spe2e_hires
    steps/compute_cmvn_stats.sh data/${trainset}
fi

if [ $stage -le 5 ]; then
  echo "$0: calling the flat-start chain recipe..."
  local/chain/e2e/run_tdnnf_flatstart_char.sh --train_set ${trainset}_spe2e_hires --test_sets "$test_sets"
fi
