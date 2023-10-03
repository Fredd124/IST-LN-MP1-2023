#!/bin/zsh

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

############## Compile Source Transducers ############
echo "Starting to compile source transducers:"
for i in sources/*.txt tests/*.txt; do
	echo "  Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

############## CORE OF THE PROJECT  ############

echo "Starting Transducers Transformations:"

    ######## mix2numerical.fst ########
fstconcat compiled/0-9.fst compiled/0-9.fst > compiled/day.fst
fstconcat compiled/day.fst compiled/day.fst > compiled/year1.fst
fstconcat compiled/slashdate.fst compiled/year1.fst > compiled/sy.fst
fstconcat compiled/day.fst compiled/sy.fst > compiled/dsy.fst
fstconcat compiled/slashdate.fst compiled/dsy.fst > compiled/sdsy.fst
fstconcat compiled/mmm2mm.fst compiled/sdsy.fst > compiled/mix2numerical.fst

rm compiled/day.fst compiled/year1.fst compiled/sy.fst compiled/dsy.fst 

echo "-> Finished mix2numerical"

    ######## pt2en.fst ########
fstconcat compiled/monthPtToEn.fst compiled/sdsy.fst > compiled/pt2en.fst

echo "-> Finished pt2en"

    ######## en2pt.fst ########
fstreverse compiled/monthPtToEn.fst > compiled/monthEnToPt.fst
fstconcat compiled/monthEnToPt.fst compiled/sdsy.fst > compiled/en2pt.fst

rm compiled/monthEnToPt.fst compiled/sdsy.fst

echo "-> Finished en2pt"

    ######## day.fst ########
fstunion compiled/0sday.fst compiled//10sday.fst > compiled/day1.fst
fstunion compiled/day1.fst compiled/20sday.fst > compiled/day2.fst
fstunion compiled/day2.fst compiled/30sday.fst > compiled/day.fst 

rm compiled/day1.fst compiled/day2.fst

echo "-> Finished day"

    ######## month.fst ########

echo "-> Finished month"

    ######## year.fst ########

echo "-> Finished year"

    ######## datenum2text.fst ########
fstconcat compiled/slash.fst compiled/year.fst > compiled/sy.fst
fstconcat compiled/comma.fst compiled/sy.fst > compiled/csy.fst
fstconcat compiled/day.fst compiled/csy.fst > compiled/dcsy.fst
fstconcat compiled/slash.fst compiled/dcsy.fst > compiled/sdcsy.fst
fstconcat compiled/month.fst compiled/sdcsy.fst > compiled/datenum2text.fst

rm compiled/sy.fst compiled/csy.fst compiled/dcsy.fst 

echo "-> Finished datenum2text"

    ######## mix2text.fst ########
fstconcat compiled/month2name.fst compiled/sdcsy.fst > compiled/mix2text.fst

echo "-> Finished mix2text"

    ######## date2text.fst #########
fstunion compiled/month.fst compiled/month2name.fst > compiled/mix2.fst
fstconcat compiled/mix2.fst compiled/sdcsy.fst > compiled/date2text.fst

rm compiled/sdcsy.fst compiled/mix2.fst

echo "-> Finished date2text"

############## Generate PDFs  ############
echo "Starting to generate PDFs:"
for i in compiled/*.fst; do
	echo "  Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

############## Test ############
echo "Starting to test:"

fst2word() {
	awk '{if(NF>=3){printf("%s",$3)}}END{printf("\n")}'
}

trans=compiled/date2text.fst

for w in compiled/t-9*.fst; do
    res=$(fstcompose $w compiled/${w:16} | fstshortestpath | fstproject --project_type=output |
            fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms-out.txt | fst2word)
    fstcompose $w compiled/${w:16}  > compiled/$(basename $w '.fst')output.fst
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt compiled/$(basename $w '.fst')output.fst \
        | dot -Tpdf > images/$(basename $w '.fst')output.pdf
    echo "  $w -> $res"
done

for w in compiled/t-0*.fst; do
    res=$(fstcompose $w $trans | fstshortestpath | fstproject --project_type=output |
            fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms-out.txt | fst2word)
    fstcompose $w $trans > compiled/$(basename $w '.fst')output.fst
    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt compiled/$(basename $w '.fst')output.fst \
        | dot -Tpdf > images/$(basename $w '.fst')output.pdf
    echo "  $w -> $res"
done


