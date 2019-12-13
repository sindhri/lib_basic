function datafilenames = get_datafilenames
    pathname = uigetdir('select the directory of the folder');
    datafilenames = dir(pathname);
    datafilenames = datafilenames(~ismember({datafilenames.name},{'.','..','.DS_Store'}));
    datafilenames = {datafilenames.name};
    
end