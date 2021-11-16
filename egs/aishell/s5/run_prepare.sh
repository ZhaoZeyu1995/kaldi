#!/usr/bin/env bash

# Copyright 2017 Beijing Shell Shell Tech. Co. Ltd. (Authors: Hui Bu)
#           2017 Jiayu Du
#           2017 Xingyu Na
#           2017 Bengu Wu
#           2017 Hao Zheng
# Apache 2.0

# This is a shell script, but it's recommended that you run the commands one by
# one by copying and pasting into the shell.
# Caution: some of the graph creation steps use quite a bit of memory, so you
# should run this on a machine that has sufficient memory.

data=$HOME/Documents/Work/CSTR/lennoxtown/s3/data
data_url=www.openslr.org/resources/33

. ./cmd.sh

local/download_and_untar.sh $data $data_url data_aishell || exit 1;
local/download_and_untar.sh $data $data_url resource_aishell || exit 1;

# Lexicon Preparation,
local/aishell_prepare_dict.sh $data/resource_aishell || exit 1;

# Data Preparation,
local/aishell_data_prep.sh $data/data_aishell/wav $data/data_aishell/transcript || exit 1;

# Phone Sets, questions, L compilation
utils/prepare_lang.sh --position-dependent-phones false data/local/dict \
    "<SPOKEN_NOISE>" data/local/lang data/lang || exit 1;

# LM training
local/aishell_train_lms.sh || exit 1;

# G compilation, check LG composition
utils/format_lm.sh data/lang data/local/lm/3gram-mincount/lm_unpruned.gz \
    data/local/dict/lexicon.txt data/lang_test || exit 1;
