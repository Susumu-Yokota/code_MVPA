all_dataset = cell(numel(ROI_filenames), numel(contrast_filenames));

for roi = 1:numel(ROI_filenames)
   %read ROI image
    roi_V = spm_vol(fullfile(ROI_folder, ROI_filenames{roi})); 
    anat_roi = spm_read_vols(roi_V);
    
    for cont = 1:numel(contrast_filenames)
        extract_beta = zeros(numel(subject_ids), sum(anat_roi(:) == 1), 'double');
        
        for sbj = 1:numel(subject_ids)
            %read contrast image
            cont_V = spm_vol(fullfile(contrast_folder_prefix, subject_ids{sbj}, contrast_folder_postfix, contrast_filenames{cont})); 
            beta = spm_read_vols(cont_V); 

            % extract beta value
            extract_beta(sbj, :) = beta(anat_roi == 1);
            
        end
        
        all_dataset{roi, cont} = extract_beta;
        
    end
end

%remove NaN
back_nan = cell(numel(ROI_filenames), numel(contrast_filenames));

for r = 1:numel(ROI_filenames)
    for c = 1:numel(contrast_filenames)
    data = all_dataset{r,c};

    data_rev = data';

    data_nan = rmmissing(data_rev);

    data_nan_fin = data_nan';

    back_nan{r,c} = data_nan_fin;
    end
end
