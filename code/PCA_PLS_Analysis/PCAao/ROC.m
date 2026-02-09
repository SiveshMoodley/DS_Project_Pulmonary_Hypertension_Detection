function [FPR,TPR,J,srA,srT,Prcn,Recl,Fbeta] = ROC(T,mPAPco,SMAco,c)

%% If statement for postive or negative correlation
if c==1 % Positive Correlation

    %% Index table for the different conditions
    % True Positive
    idx1 = T.mPAP >= mPAPco & T.smA >= SMAco;
    T1 = T(idx1,:);
    TP = height(T1);

    % False Negative
    idx2 = T.mPAP >= mPAPco & T.smA < SMAco;
    T2 = T(idx2,:);
    FN = height(T2);

    % False Positive
    idx3 = T.mPAP < mPAPco & T.smA >= SMAco;
    T3 = T(idx3,:);
    FP = height(T3);

    % True Negative
    idx4 = T.mPAP < mPAPco & T.smA < SMAco;
    T4 = T(idx4,:);
    TN = height(T4);

    % Actual Successful Classifications
    idx5 = T.mPAP >= mPAPco & T.smA >= SMAco & T.PHclass == 1;
    T5 = T(idx5,:);
    idx6 = T.mPAP < mPAPco & T.smA < SMAco & T.PHclass == 0;
    T6 = T(idx6,:);
    SucClass = height(T5) + height(T6);

elseif c==0 % Negative Correlation

    %% Index table for the different conditions
    % True Positive
    idx1 = T.mPAP >= mPAPco & T.smA <= SMAco;
    T1 = T(idx1,:);
    TP = height(T1);

    % False Negative
    idx2 = T.mPAP >= mPAPco & T.smA > SMAco;
    T2 = T(idx2,:);
    FN = height(T2);

    % False Positive
    idx3 = T.mPAP < mPAPco & T.smA <= SMAco;
    T3 = T(idx3,:);
    FP = height(T3);

    % True Negative
    idx4 = T.mPAP < mPAPco & T.smA > SMAco;
    T4 = T(idx4,:);
    TN = height(T4);

    % Actual Successful Classifications
    idx5 = T.mPAP >= mPAPco & T.smA <= SMAco & T.PHclass == 1;
    T5 = T(idx5,:);
    idx6 = T.mPAP < mPAPco & T.smA > SMAco & T.PHclass == 0;
    T6 = T(idx6,:);
    SucClass = height(T5) + height(T6);

else

    msg = 'Error occured defining correlation type.';
    error(msg)

end

%% Calculate specificity and sensitivity
%  1-Specificity - False Positive Rate
FPR = FP / (FP + TN);

% Sensitivity - True Positive Rate
TPR = TP / (TP + FN);

% Youden's Index (J Statistics)
J = TPR - FPR;

%% Calculate actual and theoretical classifying success rates
% Actual Success Rate
srA = (SucClass) / (TP + TN + FP + FN);

% Theoretical Success Rate
srT = (TP + TN) / (TP + TN + FP + FN);

%% Precision-Recall
% Precision
if (TP + FP) == 0
    Prcn = 1;
else
    Prcn = TP / (TP + FP);
end

% Recall
Recl = TPR;

% Beta
beta = 2;

% Fbeta Score
Fbeta = ((1+(beta^2)) * Prcn * Recl)/(((beta^2) * Prcn) + Recl);
