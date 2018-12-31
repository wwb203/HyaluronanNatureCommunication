# HyaluronanNatureCommunication
Supporing code and demo data for our paper submitted to Nature Communication: "Self-Regenerating Giant Hyaluronan Polymer Brushes".
Matlab files in to root directory are code snippets of the core algorithms we used to analyze microscopy images in our research.

## The follow directories contains runable demostrations for the core algorithm we used in this study:
Demostration of particle exclusion assay using dextran and 100nm or 200nm nanoparticles:
### /codeUsedForResearch/ParticleExclusionDemo
runable scripts: demoPEA200nm.m demoPEA20nm
Analysis of GPFn profile attached to hyaluronan brush
### /codeUsedForResearch/GFPnProfileDemo
runable script: GFPnDemo.m
calculation of bacteria volumes
### /codeUsedForResearch/BacteriaDemo
runable script: main.m

## The follow directories contains the raw code we used to generate the published results:
These folders needs to be seperately put in a parent folder together with a folder named 'rawData' containing *.oib from the experiments.
A new folder 'imageAnalyze' will be created by running 'batch.m' in each folder.

### Code to analyze particle exclusion assay using dextran and 100nm or 200nm nanoparticles:
/codeUsedForResearch/PEA_default
### Code to analyze particle exclusion assay using dextran and 20nm nanoparticles:
/codeUsedForResearch/PEA_20nm_wtgrafting
### Code to analyze GFPn attached to hyaluronan brushes
/codeUsedForResearch/GFPn
### Code to calculate bacteria volumes
/codeUsedForResearch/HAS Bacteria Codes
### Code to estimate the faction of membrane fragment coverage from SEM image
/codeUsedForResearch/process_SEM.m (SEM image included, directly runable)


