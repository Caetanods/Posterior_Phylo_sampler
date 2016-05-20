#!/bin/bash

# This is a script to sample trees from the posterior of the output of a BEAST run.

echo "	#################### Posterior phylo sampler 1.2 ####################"
echo "	Please check:"
echo "	First argument is the burnin percentage [0.0 to 1.0 value]"
echo "	Second argument is the number of trees to be sampled [integer]"
echo "	Third argument is the file_name of the Beast *.trees output"
echo ""
echo "	Usage example: './beast_tree_sampler_1.1 0.5 10 yourfile.trees'"
echo ""
echo "	Author: Daniel S. Caetano -- caetanods1@gmail.com"

if [[ -z $1 ]]; then
    echo ""
    echo "ERROR"
    echo ""
    echo 'Please provide the burnin percentage [0 to 1 value] as $1 (first argument).'
    exit
fi

if [[ -z $2 ]]; then
    echo ""
    echo "ERROR"
    echo ""
    echo 'Please provide the number of trees to be sampled as $2 (second argument).'
    exit
fi

if [[ -z $3 ]]; then
    echo ""
    echo "ERROR"
    echo ""
    echo 'Please provide the *.trees file as $3 (third argument).'
    exit
fi

if [[ -f $3 ]]; then
    echo ""
    echo '	Reading file '$3'...'
else
    echo ""
    echo "ERROR"
    echo ""
    echo 'File '$3' not found. Please set $3 (third argument) as the *.trees file with the MCMC chain. The output from the BEAST or Mr. Bayes run.'
    exit
fi

# Only the lines NOT starting with "tree"
HEADER=`cat $3 | sed -n '/^tree/!p'`
HLINES=`echo "$HEADER" | wc -l`

#Check if the last line is "End ;"
#If yes, then take this line out of the printed header.
#Note that additional calculations need to use the original line size of HEADER.
LAST=`echo "$HEADER" | tail -n 1`
if [[ "$LAST" == "End;" ]]; then
	LIN=$HLINES
	let LIN=LIN-1
	HEADER=`echo "$HEADER" | head -n $LIN`
fi

# Calculate the burnin:
TLINES=`wc -l < $3`
NTREES=`echo "$TLINES-$HLINES" | bc`
BURN=`echo "scale=0;$NTREES*$1" | bc`
POST=`echo "scale=0;$NTREES-$BURN" | bc`

# After all the calculations need to make sure that the answer is an integer ('awk' trick):
POSTI=`echo $POST | awk '{printf("%d\n",$1 + 0.5)}'`

BASE=`echo "$TLINES-$POSTI" | bc`

# First need to create the header of the nexus file:
echo "$HEADER" > sampled_$2_$3

# Need a function to check if one element is in the array:
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=0
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=1
            break
        fi
    done
    return $in
}

# The loop to get a random tree from the original file and print in the new one:
# Note that the random numbers are generated in python:
COUNT=0

echo ""
echo "	Sampling trees..."

while [[ "$COUNT" -lt "$2" ]]; do
  RANDO=$(python -c "import random; var1=random.randint(${BASE},${TLINES}); print var1")
  if array_contains RES $RANDO; then
    RES[COUNT]=$RANDO
    TAIL=`echo "$TLINES-$RANDO" | bc`
	if [[ $TAIL != 1 ]]; then
      tail -n $TAIL $3 | head -n 1 >> sampled_$2_$3
      let COUNT=COUNT+1
	  fi
    fi
done

echo "End;" >> sampled_$2_$3

echo ""
echo "	Finished"

exit
