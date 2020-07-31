%input multiple clusters for the particular foi_ERSP or foi_ITC
%then call ITC_fullhead_create_doi_from_foi_fho
function T_out = ITC_fullhead_create_doi_from_foi_fho_multiple(foi_struct,...
    poi_multiple,table_filename)

    for i = 1:length(poi_multiple)
            
        T_temp = ITC_fullhead_create_doi_from_foi_fho(foi_struct,...
            poi_multiple(i),'n');
    
        if i == 1
            T_out = T_temp;
        else
            T_out = join(T_out,T_temp);
        end
    end
    
    if table_filename ~= 'n' 
        writetable(T_out,table_filename,'delimiter','\t');
    end
end