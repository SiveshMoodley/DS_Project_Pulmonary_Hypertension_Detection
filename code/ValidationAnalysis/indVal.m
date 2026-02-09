function [SucPrct,TP,TN,FP,FN,spec,sens] = indVal(c,SMcutoff,T,SMs,SM)

T.Properties.VariableNames = ["Subject ID","mPAP","PH"];
h = height(T);

if c == 1
    for i = 1:h
        if  SMs(i,SM) >= SMcutoff 
                PHsm(i,:) = 1;
        else
                PHsm(i,:) = 0;
        end
    end

    % Add column to Table
    T.PHsm = PHsm;
else
    for i = 1:h
        if  SMs(i,SM) <= SMcutoff 
                PHsm(i,:) = 1;
        else
                PHsm(i,:) = 0;
        end
    end

    % Add column to Table
    T.PHsm = PHsm;  
end

%% Index for confusion matrix
% True Positive
idx1 = T.PH == 1 & T.PHsm == 1;
T1 = T(idx1,:);
TP = height(T1);

% False Negative (People with PH misclassified)
idx2 = T.PH == 1 & T.PHsm == 0;
T2 = T(idx2,:);
FN = height(T2);

% False Positive (People without PH misclassifed)
idx3 = T.PH == 0 & T.PHsm == 1;
T3 = T(idx3,:);
FP = height(T3);

% True Negative
idx4 = T.PH == 0 & T.PHsm == 0;
T4 = T(idx4,:);
TN = height(T4);

mPAP = T.mPAP;
smA = SMs(:,SM);

% Successful Classifications
SucCls = TP + TN;
SucPrct = 100 * (SucCls/h);

% Sensitivity and Specificity
sens = TP / (TP + FN);
spec = FP / (FP + TN);
