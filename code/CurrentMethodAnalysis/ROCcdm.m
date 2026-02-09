function [FPR,TPR,Prcn,Recl] = ROCcdm(T,mPAPco,Aco)

%% Index table for the different conditions
% True Positive
idx1 = T.mPAP >= mPAPco & T.Amount >= Aco;
T1 = T(idx1,:);
TP = height(T1);

% False Negative
idx2 = T.mPAP >= mPAPco & T.Amount < Aco;
T2 = T(idx2,:);
FN = height(T2);

% False Positive
idx3 = T.mPAP < mPAPco & T.Amount >= Aco;
T3 = T(idx3,:);
FP = height(T3);

% True Negative
idx4 = T.mPAP < mPAPco & T.Amount < Aco;
T4 = T(idx4,:);
TN = height(T4);

%% Calculate s and sensitivity
%  1-Specificity - False Positive Rate
FPR = FP / (FP + TN);

% Sensitivity - True Positive Rate
TPR = TP / (TP + FN);

%% Precision-Recall
% Precision
if (TP + FP) == 0
    Prcn = 1;
else
    Prcn = TP / (TP + FP);
end

% Recall
Recl = TPR;
