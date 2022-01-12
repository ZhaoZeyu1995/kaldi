#!/usr/bin/env bash

stage=0
train=true   # set to false to disable the training-related scripts
             # note: you probably only want to set --train false if you
             # are using at least --stage 1.
decode=true  # set to false to disable the decoding-related scripts.

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. utils/parse_options.sh  # e.g. this parses the --stage option if supplied.


# This is a shell script, but it's recommended that you run the commands one by
# one by copying and pasting into the shell.

#wsj0=/ais/gobi2/speech/WSJ/csr_?_senn_d?
#wsj1=/ais/gobi2/speech/WSJ/csr_senn_d?

#wsj0=/mnt/matylda2/data/WSJ/WSJ0
#wsj1=/mnt/matylda2/data/WSJ/WSJ1

#wsj0=/data/corpora0/LDC93S6B
#wsj1=/data/corpora0/LDC94S13B

#wsj0=/export/corpora5/LDC/LDC93S6B
#wsj1=/export/corpora5/LDC/LDC94S13B


if [ $stage -le 0 ]; then
  # data preparation.
  #local/wsj_data_prep.sh $wsj0/??-{?,??}.? $wsj1/??-{?,??}.?  || exit 1;

  # Sometimes, we have seen WSJ distributions that do not have subdirectories
  # like '11-13.1', but instead have 'doc', 'si_et_05', etc. directly under the
  # wsj0 or wsj1 directories. In such cases, try the following:
  #
  corpus=/group/corpora/public/wsj
  local/cstr_wsj_data_prep.sh $corpus
  rm data/local/dict/lexiconp.txt
  # $corpus must contain a 'wsj0' and a 'wsj1' subdirectory for this to work.
  #
  # "nosp" refers to the dictionary before silence probabilities and pronunciation
  # probabilities are added.
  local/wsj_prepare_dict.sh --dict-suffix "_nosp" || exit 1;

  local/wsj_prepare_char_dict.sh 

  utils/prepare_lang.sh --position-dependent-phones false data/local/dict_char \
                        "<SPOKEN_NOISE>" data/local/lang_tmp_nosp data/lang_nosp || exit 1;

  local/wsj_format_data.sh --lang-suffix "_nosp" || exit 1;

  # We suggest to run the next three commands in the background,
  # as they are not a precondition for the system building and
  # most of the tests: these commands build a dictionary
  # containing many of the OOVs in the WSJ LM training data,
  # and an LM trained directly on that data (i.e. not just
  # copying the arpa files from the disks from LDC).
  # Caution: the commands below will only work if $decode_cmd
  # is setup to use qsub.  Else, just remove the --cmd option.
  # NOTE: If you have a setup corresponding to the older cstr_wsj_data_prep.sh style,
  # use local/cstr_wsj_extend_dict.sh --dict-suffix "_nosp" $corpus/wsj1/doc/ instead.
  #(
    #local/wsj_extend_dict.sh --dict-suffix "_nosp" $wsj1/13-32.1  && \
      #utils/prepare_lang.sh data/local/dict_nosp_larger \
                            #"<SPOKEN_NOISE>" data/local/lang_tmp_nosp_larger data/lang_nosp_bd && \
      #local/wsj_train_lms.sh --dict-suffix "_nosp" &&
      #local/wsj_format_local_lms.sh --lang-suffix "_nosp" # &&
  #) &

  # Now make MFCC features.
  # mfccdir should be some place with a largish disk where you
  # want to store MFCC features.

  for x in test_eval92 test_eval93 test_dev93 train_si284; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj 20 data/$x || exit 1;
    steps/compute_cmvn_stats.sh data/$x || exit 1;
  done

  utils/subset_data_dir.sh --first data/train_si284 7138 data/train_si84 || exit 1

  # Now make subset with the shortest 2k utterances from si-84.
  utils/subset_data_dir.sh --shortest data/train_si84 2000 data/train_si84_2kshort || exit 1;

  # Now make subset with half of the data from si-84.
  utils/subset_data_dir.sh data/train_si84 3500 data/train_si84_half || exit 1;
fi
