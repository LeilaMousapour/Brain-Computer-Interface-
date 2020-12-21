function output(outputfilename, sources, eeg, elec)

slresult = [];
slresult.sources = sources;
slresult.eeg     = eeg;
slresult.elec    = elec;

output_path = fullfile(cd);
outputfilename_path = fullfile(output_path,'output', outputfilename);
fprintf('The result of source localization is saved in the output folder');
save(outputfilename_path, '-struct', 'slresult');

end
