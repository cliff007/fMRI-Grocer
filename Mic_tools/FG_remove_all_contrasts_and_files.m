function FG_remove_all_contrasts_and_files(SPM_file)
files=spm_select(inf,'SPM.mat','Select all the SPM.mat files that need to remove contrasts', [],pwd); 
if FG_check_ifempty_return(files), return,end

for i=1:size(files,1)
    SPM_file=deblank(files(i,:));

    % Change to the analysis directory
    %-----------------------------------------------------------------------
    if ~isempty(SPM_file)
        try
            pth = fileparts(SPM_file);
            cd(char(pth));
            % fprintf('   Changing directory to: %s\n',char(pth));
        catch
            error('Failed to change directory. Aborting contrast setup.')
        end
    end

    % Load SPM.mat file
    %-----------------------------------------------------------------------
    load(SPM_file,'SPM');

    try
        SPM.xVol.XYZ;
    catch
        error('This model has not been estimated.');
    end

    if ~strcmp(pth,SPM.swd)
        warning(['Path to SPM.mat: %s\n and SPM.swd: %s\n differ, using current ' ...
                 'SPM.mat location as new working directory.'], pth, ...
                SPM.swd);
        SPM.swd = pth;
    end

    if isfield(SPM,'xCon') && ~isempty(SPM.xCon)
        for k=1:numel(SPM.xCon)
            if ~isempty(SPM.xCon(k).Vcon)
                [p n e v] = spm_fileparts(SPM.xCon(k).Vcon.fname);
                switch e,
                    case '.img'
                        spm_unlink([n '.img'],[n '.hdr']);
                    case '.nii'
                        spm_unlink(SPM.xCon(k).Vcon.fname);
                end
            end
            if ~isempty(SPM.xCon(k).Vspm)
                [p n e v] = spm_fileparts(SPM.xCon(k).Vspm.fname);
                switch e,
                    case '.img'
                        spm_unlink([n '.img'],[n '.hdr']);
                    case '.nii'
                        spm_unlink(SPM.xCon(k).Vspm.fname);
                end
            end
        end
        SPM.xCon = [];
        save 'SPM.mat' SPM

        fprintf('\nContrasts and related result-files have been removed from this SPM.mat file: \n %s \n\n',SPM_file);
    else
        fprintf('\nThere is no contrast in this SPM.mat file: \n %s \n\n',SPM_file);
    end

end

        fprintf('\nDone!\n');
