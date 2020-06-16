function doi = ITC_combine_doi_addcol(doi1, doi2)

    doi = doi1;
    doi.data_2d = [doi1.data_2d doi2.data_2d];
    doi.type = strcat(doi1.type, '_', doi2.type);
    doi.id = doi1.id;
    n = length(doi1.label);
    for i = 1:length(doi2.label)
        doi.label(n+i,1) = doi2.label(i,1);
    end
    
    doi_export_2d_to_text(doi);
end

function doi_export_2d_to_text(doi)
data_2d = doi.data_2d;
type = doi.type;
subject_list = doi.id;
extra_filename = doi.extra_filename;

for i = 1:length(doi.label)
    label{i,1} = doi.label{i};
end

d = dataset({data_2d,label{:}},'obsnames',subject_list);
exported_filename = ['export_' type extra_filename '.txt'];
export(d,'file',exported_filename);

end
