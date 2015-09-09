function FG_read_the_name_of_AAL_list
clc
[a,b,c,d]=fileparts(which('fmri_grocer'));
FG_aal=load([a filesep 'Templates' filesep 'aal_regions.mat']);
aal_file = spm_select(1,'.m','Select the AAL region name file:', [],[a filesep 'Mic_tools'],'^FG_AAL_names_list*.*m');
addpath(FG_sep_group_and_path(aal_file));
[a,b,c,d]=fileparts(aal_file);
AAL_names=eval(b);

k=1;
for i=1:size(AAL_names,1)
    for j=1:size(FG_aal.aal_regions,1)
        if strcmp(AAL_names{i},FG_aal.aal_regions{j,2})
            results{k}=FG_aal.aal_regions{j,1}(1,1:end-5);
            k=k+1;
        end
    end
end
fprintf('\n--The results of your inquiry are \n')
results'
fprintf('\n\n')