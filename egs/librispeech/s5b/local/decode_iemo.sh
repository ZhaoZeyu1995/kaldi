#!/bin/bash

for test in "iemo"; do
  steps/decode_fmllr.sh --nj 10 --cmd "run.pl" \
                        exp/tri6b/graph_tgsmall data/$test exp/tri6b/decode_tgsmall_$test
  steps/lmrescore.sh --cmd "run.pl" data/lang_test_{tgsmall,tgmed} \
                     data/$test exp/tri6b/decode_{tgsmall,tgmed}_$test
  steps/lmrescore_const_arpa.sh \
    --cmd "run.pl" data/lang_test_{tgsmall,tglarge} \
    data/$test exp/tri6b/decode_{tgsmall,tglarge}_$test
  steps/lmrescore_const_arpa.sh \
    --cmd "run.pl" data/lang_test_{tgsmall,fglarge} \
    data/$test exp/tri6b/decode_{tgsmall,fglarge}_$test
done
