function p02_03_spectro_fooof(s)

%if this step is required
if s.todo.spectro_fooof

  try
    %add python and fooof 
    [~, ~, isloaded] = pyversion;
    if isloaded
        disp('To change the Python version, restart MATLAB, then call pyversion.')
    else
        pyversion(s.path.python);
    end
    insert(py.sys.path,int32(0), s.path.fooof(1:end-1));
    addpath(s.path.fooof);
    clear isloaded;
    pyversion
  end

  %find all input folders
  %here: specdata.mat in results/process/SUBJFOLDER/
  folders = dir(s.path.process); 
  folders = folders(contains({folders.name},'NDAR'));

  %loop over subject data..
  %..serial processing
  %loop over folders
  for i=1:length(folders)
    pl_fooof(folders(i), folders(i), s);
  end

end