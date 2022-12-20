%d score
D = readtable('dscore_regroup.xlsx');
%d score for ASD
label_A = D{:,1};
%Dscore for physical disabilities
label_P = D{:,2};

%load extracted beta value
load('all_dataset_putamen_ASD.mat')
ASD = back_nan
load('all_dataset_1back_regroup_physical.mat')
Phy = back_nan

%mse
mse_A = zeros(10,7);
mse_P = zeros(10,7);

% assing personal ID
uniq_sub_id = 1:6;
sample_sub_id = repelem(uniq_sub_id, 6);

%permutation test
no_iter = 5000;
no_ss = 36;

%mse by permutation test
mse_perm_A =  zeros(no_iter,1);
mse_perm_P = zeros(no_iter,1);

%mseÇäiî[Ç∑ÇÈÉZÉãçsóÒÇèÄîı
hist_mse_A = cell(10,7);
hist_mse_P = cell(10,7);

%p value
mse_p_perm_A = zeros(10,7);
mse_p_perm_P = zeros(10,7);

%%
%observed data

%ASD
for r = 1:size(corr_A, 1)

    for c = 1:size(corr_A, 2)
        
        x = ASD{r, c}; 
        y = label_A;
        predicted_label_A = zeros(size(y), 'double');

        for each_id = uniq_sub_id
            
            train_ind = find(sample_sub_id ~= each_id);
            test_ind = find(sample_sub_id == each_id);
            
            model = svmtrain(y(train_ind), x(train_ind, :), '-s 3 -t 0');
            
            predicted_label_A(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
        end
        
        %calcurate mse
        d = predicted_label_A - label_A;
        d2 = sum(d.^2);
        mse = d2/size(y,1);
        
        mse_A(r,c) = mse;
    end
end

%physical
for r = 1:size(corr_P, 1)

    for c = 1:size(corr_P, 2)
        
        x = Phy{r, c}; 
        y = label_P;
        predicted_label_P = zeros(size(y), 'double');

        for each_id = uniq_sub_id
            
            train_ind = find(sample_sub_id ~= each_id);
            test_ind = find(sample_sub_id == each_id);
            
            model = svmtrain(y(train_ind), x(train_ind, :), '-s 3 -t 0');
            
            predicted_label_P(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
        end
        
        %calculate mse
        d = predicted_label_P - label_P;
        d2 = sum(d.^2);
        mse = d2/size(y,1);
        
        mse_P(r,c)= mse;
    end
end


%%
%permutation

%ASD
for r = 1:size(corr_A, 1)

    for c = 1:size(corr_A, 2)
        %randomize
        for it = 1:1:no_iter
            label_A_perm = label_A(randperm(no_ss));
    
            x = ASD{r, c}; 
            y = label_A_perm;
            predicted_label_A = zeros(size(y), 'double');

            for each_id = uniq_sub_id
            
                train_ind = find(sample_sub_id ~= each_id);
                test_ind = find(sample_sub_id == each_id);
            
                model = svmtrain(y(train_ind), x(train_ind, :), '-s 3 -t 0');
            
                predicted_label_A(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
            end
        
        %calculate mse
            d = predicted_label_A - label_A;
            d2 = sum(d.^2);
            mse = d2/size(y,1);
        
            mse_perm_A(it,1) = mse;
        end
         
            hist_corr_A{r,c} = corr_perm_A;
            hist_mse_A{r,c} = mse_perm_A;
            
        %p value
        sort_mse_perm_A = sort(mse_perm_A, 'ascend');
        if sort_mse_perm_A(1) <= mse_A(r,c)
           position_mse_A = find(sort_mse_perm_A <= mse_A(r,c));
        else position_mse_A = 1;
        end
        
        pval_mse = position_mse_A(end)/no_iter;
        mse_p_perm_A(r,c) = pval_mse;
    end
end

%physical
for r = 1:size(corr_P, 1)

    for c = 1:size(corr_P, 2)
        for it = 1:1:no_iter
            label_P_perm = label_P(randperm(no_ss));
            
        x = Phy{r, c}; 
        y = label_P_perm;
        predicted_label_P = zeros(size(y), 'double');

        for each_id = uniq_sub_id
            
            train_ind = find(sample_sub_id ~= each_id);
            test_ind = find(sample_sub_id == each_id);
            
            model = svmtrain(y(train_ind), x(train_ind, :), '-s 3 -t 0');
            
            predicted_label_P(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
        end
        
        %calculate mse
        d = predicted_label_P - label_P;
        d2 = sum(d.^2);
        mse = d2/size(y,1);
        
        mse_perm_P(it,1)= mse;
        end
        
        hist_mse_P{r,c} = mse_perm_P;
                 
        %p value
        sort_mse_perm_P = sort(mse_perm_P, 'ascend');
         if sort_mse_perm_P(1) <= mse_P(r,c)
            position_mse_P = find(sort_mse_perm_P <= mse_P(r,c));
        else position_mse_P = 1;
        end
        
        pval_mse = position_mse_P(end)/no_iter;
        mse_p_perm_P(r,c) = pval_mse;       
   end
end