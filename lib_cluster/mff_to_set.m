function mff_to_set

pathname = uigetdir('Select the folder of mff files to convert to set');
filenames = dir(pathname);
filenames = {filenames.name};
filenames = filenames(~ismember(filenames,{'.','..','.DS_Store'}));

for i = 1:length(filenames)
    EEG = mff_import([pathname filesep filenames{i}]);
    pop_saveset(EEG,[pathname filesep strrep(filenames{i},'.mff','.set')]);
end