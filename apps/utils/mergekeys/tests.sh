#!/bin/bash

# test 00 - 1:1 matching between both files
# test 01 - both files have just a header
# test 02 - file A has just a header; B has data
# test 03 - A has data; file B has just a header
# test 04 - last line of A is greater than last line of B
# test 05 - last line of A is less than last line of B
# test 06 - case-insensitive string collation (assumes local en_US.iso88591)
# test 07 - one:many relationship between keys in A and B


wdir=`dirname $0`

subtests=(00 01 02 03 04 05 06 07 08)
datadir=$wdir/tests
test_delim='\t'

tests=("" "-l" "-r" "-i")
test_names=("full outer" "left outer" "right outer" "inner")
errors=0

for i in `seq 0 $(( ${#tests[*]} - 1 ))`; do

	echo "" # just put an empty line for readability

	optstring=`echo ${tests[$i]} | sed 's/\s//g'`

	for t in ${subtests[*]}; do

		left=$datadir/test_${t}.a
		right=$datadir/test_${t}.b
		expected=$datadir/test_${t}.${optstring}.expected
		out=$datadir/test_${t}.${optstring}.out

		if [ -e $expected ]; then

			echo -n "test $i - \"${test_names[$i]}\" (sub test ${t}): "

			$wdir/mergekeys -d "$test_delim" $optstring $left $right > $out

			if [ "`diff -q $out $expected`" ]; then
				(( errors++ ))
				echo "failed"
				echo "		see $out"
			else
				echo "passed"
				rm $out
			fi

		else

			echo "creating $expected from $left, $right and options ${tests[$i]}"

			$wdir/mergekeys -d "$test_delim" $optstring $left $right > $expected

		fi

	done

done

echo -e "\n$errors errors\n"