#!/bin/bash

echo "Setting project=$project"
project="$project"
echo "Setting username=shirin"
username="shirin"

echo "Setting virtual environment"
source .bashrc

echo "source runai/${workspace}_env"
source runai/"${workspace}_env"
echo "conda activate $project_venv"
conda activate ${project_venv}

which python

echo "Setting datadir=/mydata/$project/$username/${data_dir}"
datadir="/mydata/$project/$username/${data_dir}"
echo "Setting codedir=/mydata/$project/$username/${code_dir}"
codedir="/mydata/$project/$username/${code_dir}"

echo "cd $codedir"
cd $codedir

