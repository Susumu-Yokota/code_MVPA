D = readtable('condition.xlsx');
%condition
label = D{:,1};

%extracted beta value
load('dataset.mat')
beta = dataset;

%predicted value
predicted_value = zeros(10,1);

%mse
mse_A = zeros(10,1);
mse_P = zeros(10,1);

% assign sample ID
sample_sub_id = 1:72;

%permutation test
no_iter = 5000;
no_ss = 72;

%accuracy by permutation
accuracy_perm = zeros(no_iter,1);

%p value
acc_p_perm = zeros(10,1);
%%

%observed data
for r = 1:size(predicted_value, 1)
        x = beta{r, 1};
        y = label;
        predicted_label = zeros(size(y), 'double');

        for each_id = sample_sub_id
            
            train_ind = find(sample_sub_id ~= each_id);
            test_ind = find(sample_sub_id == each_id);
            
            model = svmtrain(y(train_ind), x(train_ind, :), '-s 0 -t 0');
            
            predicted_label(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
            n_acc = label == predicted_label;
            accuracy = sum(n_acc) / 72;
        end
        
        predicted_value(r,1) = accuracy;
        
end

%%
%permutation

for r = 1:size(predicted_value, 1)
    for it = 1:1:no_iter
        label_perm = label(randperm(no_ss));
    
            x = beta{r, 1}; 
            y = label_perm;
            predicted_label = zeros(size(y), 'double');

            for each_id = sample_sub_id
            
                train_ind = find(sample_sub_id ~= each_id);
                test_ind = find(sample_sub_id == each_id);
            
                model = svmtrain(y(train_ind), x(train_ind, :), '-s 0 -t 0');
            
                predicted_label(test_ind) = svmpredict(y(test_ind), x(test_ind, :), model, '-q');
                n_acc = label == predicted_label;
                accuracy = sum(n_acc) / 72;
            end
               
            %accuracy
            accuracy_perm(it, 1) = accuracy;
            
        end
        hist_acc{r,1} = accuracy_perm;
            
        sort_accu_perm = sort(accuracy_perm, 'descend');
        if sort_accu_perm(1) >= predicted_value(r,1)
           position_acc = find(sort_accu_perm >= predicted_value(r,1));
        else position_acc = 1;
        end
        
        %p value
        pval_corr = position_acc(end)/no_iter;
        acc_p_perm(r,1) = pval_corr;
end
filename = 'resl_permutation.mat';
save(filename);
