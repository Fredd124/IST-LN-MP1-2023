# LN-Mini-Project-1

## Compile 
`fstcompile --isymbols=symbolsfile.txt --osymbols=symbolsfile.txt fst.txt > fstarcsort fst.fst`

## Draw
`fstdraw --portrait --isymbols=symbolsfile.txt --osymbols=symbolsfile.txt fst.fst | dot -Tpdf > fst.pdf`
