# Master's Dissertation: Assessing the Feasibility of Using Statistical Shape Modelling to Detect Pulmonary Hypertension

## Project Overview
- Developed a non-invasive machine learning framework to assess the feasibility of detecting Pulmonary Hypertension (PH) from CT imaging using Statistical Shape Modelling (SSM).
- Implemented a full data preprocessing workflow to prepare 3D vascular geometries in .VTK ecosystem, including mesh smoothing, denoising, decimation and anatomical alignment using Laplacian and Taubin filters and Procrustes algorithm.
- Constructed diffeomorphic atlases from computed shape momenta of the pulmonary artery and aorta in python using deformetrica.
- Engineered features (shape modes) from the atlases which correlate to clinical thresholds of elevated mean pulmonary arterial pressure (mPAP ≥ 25mmHg & ≥ 20mmHg) using Principal Component Analysis (PCA) and Partial Least Squares (PLS) Regression.
- Evaluated diagnostic capability using AUCROC and Precision-Recall validators, achieving:
  - AUCROC: 0.718 (PCA) and 0.734 (PLS)
  - Sensitivity: 0.744 (PCA) and 0.837 (PLS) for correct PH identification
  - Specificity: Limited 0.615 (PCA) and 0.346 (PLS) for correct non-PH identification
- The model demonstrated that application of SSM has the potential to reduce reliance on invasive right-heart catheterisation and significantly shorten diagnostic timelines but requires model and data optimisation.
- An imbalanced dataset was a key limitation, whilst increasing dataset size, data augmentation, combining shape modes and incorporating deep learning like Variational Autoencoder based SSM or Graphical Convolutional Networks on meshes could improve performance.

## Master's Dissertation
**Full Dissertation Report (PDF):**
[View Dissertation - PDF](dissertation/Masters-Dissertation-Pulmonary-Hypertension-Detection-SSGM.pdf)

## Code and Resources Used
Python Version:

Packages:

## Problem


## Dataset
### Data Statement
The dataset provided in this repository is a **synthetic sample created solely for demonstration purposes**.  
It does not contain any real NHS or patient-derived information.

- All values have been manually generated and do not correspond to any identifiable individual  
- Study identifiers are fictional and unrelated to those used in the dissertation research  
- Clinical measurements are illustrative only and should not be interpreted as real medical data  
- The synthetic dataset is included only to allow readers to understand the structure of the code and workflow

The analyses described in the dissertation were conducted on real clinical data under appropriate approvals; however, that data is not shared publicly in this repository under UK GDPR, Data Protection Act 2018 and NHS Guidance regulations.


## Data Pre-Processing


### Model Building


## Model Performance and Evaluations

## Copyright and Permissions
© 2024 Sivesh Saien George Moodley

All rights reserved.

This repository, including the source code, documentation, figures, and dissertation-related materials, is the intellectual property of the author. The content may not be reproduced, distributed, modified, or used for derivative works without prior written permission from the author.

The synthetic dataset included in this repository is provided for viewing and educational understanding only and must not be represented as real clinical data or reused without permission.


## Acknowledgements
- My supervisor Dr. Andrew Cookson at the University of Bath
- PhD Liam Burrows at the University of Bath
- This work was conducted as part of a university dissertation project. Real clinical data used in the research remains subject to NHS and institutional governance and is not included in this repository.
