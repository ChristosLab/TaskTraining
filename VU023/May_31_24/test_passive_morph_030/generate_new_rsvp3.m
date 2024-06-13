function generate_new_rsvp3
%temp_vec=repmat([1:44],1,5); %44 condition repeat 5 times
temp_vec=repmat([23:33],1,21); %11 condition repeat 5 times
stim_seq=temp_vec(randperm(length(temp_vec)));
load('RSVP3_classes.mat');
seq_count=0;
    for i=1:77
        for j=1:3
            seq_count=seq_count+1;
            GeneralVars.ClassStructure(i).frame(j).stim.feature=stim_seq(seq_count);
            GeneralVars.ClassStructure(i).frame(j).stim.end=[0,0];
        end
    end
save RSVP3_classes.mat GeneralVars    
end