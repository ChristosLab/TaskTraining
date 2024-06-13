function generate_new_rsvp1
temp_vec=repmat([1:44],1,5); %each condition repeat 5 times
stim_seq=temp_vec(randperm(length(temp_vec)));
load('RSVP1_classes.mat');
seq_count=0;
    for i=1:220
        for j=1:1
            seq_count=seq_count+1;
            GeneralVars.ClassStructure(i).frame(j).stim.feature=stim_seq(seq_count);
            GeneralVars.ClassStructure(i).frame(j).stim.end=[0,0];
        end
    end
save RSVP1_classes.mat GeneralVars    
end