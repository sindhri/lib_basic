%create continuity in data, by deleting the smaller part
%input [1,2,7,8,9,10,11,12,13,14]
%output [7,8,9,10,11,12,13,14]

function data = testContinuity(data,length_threshold)

if ~isempty(data) && length(data) > length_threshold
   a = 1;
   b = 2;
   while(a < length(data))
        if data(a)+1~=data(b)
           if a-1 < length(data)-b
              if a > 1
                 data(1:a) =[];
              else
                 data(1)=[];
              end
           else
               if b < length(data) 
                  data(b:length(data)) = [];
               else
                  data(length(data))=[];
               end
           end
           a = 1;
           b = 2;
        else
           a = a+1;
           b = b+1;
        end
   end
end