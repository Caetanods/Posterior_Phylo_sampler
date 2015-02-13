# Posterior_Phylo_sampler

Script to sample random trees from large nexus files with posterior distribution of trees.

The arguments of the program are:

First argument is the burnin percentage [a value between 0.0 and 1.0]

Second argument is the number of trees to be sampled [a integer value]

Third argument is the file_name of the *.trees output

Usage example:

'./post_phylo_sampler.sh 0.5 10 yourfile.trees'
