function [avg_time, hit_rate, responses] = get_trainning_results(trainning_csv_path)

[hits, time] = csvimport(trainning_csv_path, 'columns', {'hits', 'time'});

avg_time = mean(time);

[occur,values] = hist(hits,unique(hits));

values_size = size(values);
values_size = values_size(1); % 1: tudo certo/errado 2: respostas mistas

if(values_size == 2)
    responses = occur(1)+occur(2);
    hit_rate = occur(2)/responses;
else
   if (values == 0)
       responses = occur;
       hit_rate = 0;
   else
       responses = occur;
       hit_rate = 1;
   end
end

end

