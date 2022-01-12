#!/bin/bash

# This script compiles the ARPA-formatted language models into FSTs. Finally it composes the LM, lexicon
# and token FSTs together into the decoding graph. 

. ./path.sh || exit 1;

langdir=$1

lmdir=data/local/nist_lm
tmpdir=data/local/graph_tmp
mkdir -p $tmpdir

# These language models have been obtained when you run local/wsj_data_prep.sh
echo "Preparing language models for testing, may take some time ... "
    
    # Compose the final decoding graph. The composition of L.fst and G.fst is determinized and
    # minimized.
fsttablecompose ${langdir}/L_disambig.fst ${langdir}/G.fst | fstdeterminizestar --use-log=true | \
  fstminimizeencoded | fstarcsort --sort_type=ilabel > $tmpdir/LG.fst || exit 1;
fsttablecompose ${langdir}/T.fst $tmpdir/LG.fst > ${langdir}/TLG.fst || exit 1;

echo "Composing decoding graph TLG.fst succeeded"
rm -r $tmpdir
