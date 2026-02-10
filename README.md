# Master's Dissertation: Assessing the Feasibility of Using Statistical Shape Modelling to Detect Pulmonary Hypertension

## Project Overview
- Developed a non-invasive machine learning framework to assess the feasibility of detecting Pulmonary Hypertension (PH) from CT imaging using Statistical Shape Modelling (SSM).
- Implemented a full data preprocessing workflow to prepare 3D vascular geometries in .VTK ecosystem, including:
  - mesh smoothing and denoising using Laplacian and Taubin filters
  - decimation
  - anatomical alignment using the Procrustes algorithm
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
Python Version: 3.8

Packages: deformetrica, pytorch, numpy, matplotlib, vtk

Python Requirements: pip install -r requirements.txt

## Problem
Pulmonary Hypertension is difficult to diagnose due to symptom overlap with other cardiopulmonary diseases and reliance on invasive right-heart catheterisation, leading to diagnostic delays of several years. This project investigates whether Statistical Shape Modelling of CT-derived pulmonary artery and aorta geometry can provide a reliable, non-invasive method to support earlier detection.

## Dataset
The dataset used consists of 95 CT-derived 3D vascular geometries and associated clinical metadata for each subject.
- .nii CT scan files (NIfTI format) which store 3D medical imaging data
- Relevant clinical metadata used:
  - Mean Pulmonary Arterial Pressure (mPAP)
  - Pulmonary Artery to Aorta Ratio (PA:A)
  - Pulmonary Vascular Resistance (PVR)

### Data Statement
The dataset provided in this repository is a **synthetic sample created solely for demonstration purposes**.  
It does not contain any real NHS or patient-derived information.

- All values have been manually generated and do not correspond to any identifiable individual  
- Study identifiers are fictional and unrelated to those used in the dissertation research  
- Clinical measurements are illustrative only and should not be interpreted as real medical data  
- The synthetic dataset is included only to allow readers to understand the structure of the code and workflow

The analyses described in the dissertation were conducted on real clinical data under appropriate approvals; however, that data is not shared publicly in this repository under UK GDPR, Data Protection Act 2018 and NHS Guidance regulations.

## Data Pre-Processing
- Constructed dataset from segmented CT scans of the main pulmonary artery and aorta
- Converted segmentations to .vtk 3D surface meshes and performed:
  - Denoising and smoothing to remove artefacts, such the model represents true biological shape variation and improve computation efficiency
  - Mesh decimation to standardise resolution and reduce computation complexity
  - Anatomical alignment ensuring a common coordinate system so the model will not mistakenly interpret differences in position as actual anatomical variation
- Generated a statistical atlas using diffeomorphic registration to compute a mean template, where each subjects deformations from the template were represented by momenta vectors
- mPAP labels were matched to their corresponding mesh for PH classification

### Model Building
- Applied Principal Component Analysis (PCA) to extract dominant unsupervised shape modes capturing geometric variance
- Applied Partial Least Squares (PLS) to learn supervised shape modes maximally correlated with elevated mPAP
- Quantified the amount of each shape mode per subject and analysed associations with PH
- Models were analysed under two clinical definitions of PH to assess robustness

## Model Performance and Evaluations
- Evaluated diagnostic ability using AUCROC and Precision-Recall curves
- Key results for most discriminative modes:
  - PLS Shape Mode 1: AUCROC = 0.734, Sensitivity = 0.837, Specificity = 0.346
  - PCA Shape Mode 1: AUCROC = 0.718, Sensitivity = 0.744, Specificity = 0.615
- Validated on unseen patient data, showing feasible generalisation but limited specificity for healthy cases
- Demonstrated potential for a non-invasive pre-screening tool to reduce reliance on right-heart catheterisation and significantly cut diagnostic times, but requires model and data optimisation to improve performance

## Copyright and Permissions
© 2024 Sivesh Saien George Moodley

All rights reserved.

This repository, including the source code, documentation, figures, and dissertation-related materials, is the intellectual property of the author. The content may not be reproduced, distributed, modified, or used for derivative works without prior written permission from the author.

The synthetic dataset included in this repository is provided for viewing and educational understanding only and must not be represented as real clinical data or reused without permission.


## Acknowledgements
- My supervisor Dr. Andrew Cookson at the University of Bath
- PhD Liam Burrows at the University of Bath
- This work was conducted as part of a university dissertation project. Real clinical data used in the research remains subject to NHS and institutional governance and is not included in this repository.
