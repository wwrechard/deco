# DECO
This repository holds the code for decorrelated distributed sparse regression. 
Contact: [Xiangyu Wang](https://github.com/wwrechard) and [Chenlei Leng](https://github.com/chenleileng).
Lasso paper: [DECOrrelated feature space partitioning for distributed sparse regression](https://papers.nips.cc/paper/6349-decorrelated-feature-space-partitioning-for-distributed-sparse-regression)

## Description
The algorithm is for distributed sparse regression based on feature partitioning (against the sample partitioning). It features a decorrelation technique which yield consistent estimation results even we partition the large model into smaller ones. The code works for linear regression models and supports lasso, scad and mcp as penalty function.

## Code structure
The package relies on external packages to provide support for sparse regression. We currenlty use [`glmnet`](https://web.stanford.edu/~hastie/glmnet_matlab/) for lasso and [`SparseReg`](https://github.com/Hua-Zhou/SparseReg) for scad and mcp. These two libraries are currently included in this repository just for easy use but we do not claim any ownership nor taking any responsibility for any issue relevant to these libraries. Users can modify the interface and replace these libraries with any libraries with similar functionality.

The parallelism in `DECO` is based on the `parfor` function from `MATLAB`. `parfor` is a unified parallelism API provided by `MATLAB` that automatically employs local cores as parallel workers when invoked in a single machine. For distributed over multiple machines, users need to follow the instructions from MathWorks.

# Disclaimer
The LISCENCE in this repository is only for the code of `DECO`. For using `glmnet` and `SparseReg`, please follow their own LISCENCE and distribute accordingly.

If you used any of the two libraries in your code please do cite the individual packages.
