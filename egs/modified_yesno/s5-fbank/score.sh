exp=exp/mono_train_yyn_10
pytorchdir=~/Documents/Work/CSTR/lennoxtown/s3/pytorch-kaldi/exp/modified_yesno_BLSTMP_mfcc_yyn_60_1

for x in test_yyn test_ynn test_3gram test_sam_yyn test_sam_ynn test_sam_3gram test_sam_yyn_noise test_sam_ynn_noise test_sam_3gram_noise; do
    notest=${x#*_}
    graphdir=$exp/graph_tgpr_${notest}
    dir=${pytorchdir}/decode_${x}_out_dnn2
    echo "$notest, $graphdir, $dir"
    local/score.sh data/$x $graphdir $dir
done
