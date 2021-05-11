#!/usr/bin/env bash

for x in train_yyn dev_yyn test_yyn test_sam_yyn test_sam_yyn_noise; do
    steps/align_si.sh --nj 1 data/$x data/lang_test_yyn exp/mono_train_yyn_400 exp/mono_ali_$x
done
for x in train_ynn dev_ynn test_ynn test_sam_ynn test_sam_ynn_noise; do
    steps/align_si.sh --nj 1 data/$x data/lang_test_ynn exp/mono_train_ynn_400 exp/mono_ali_$x
done
for x in train_3gram dev_3gram test_3gram test_sam_3gram test_sam_3gram_noise; do
    steps/align_si.sh --nj 1 data/$x data/lang_test_3gram exp/mono_train_3gram_10 exp/mono_ali_$x
done
