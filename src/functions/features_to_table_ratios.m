function tbl = features_to_table_fbands(eyes, inputdata, s)

  %temporary column-wise table 
  currtab = struct2table(inputdata.Ratios);

  %loop over rows to update the variable name
  for i = 1:size(currtab,1)

    name = currtab.name{i};
    str = split(name,'__');
    for j=1:length(str)-1
      str(j)={str{j}(~[str{j}=='_'])};
    end

    cstr = str{end};
    idx = find(cstr=='_',1,'last')-1;
    clust1 = cstr(1:idx-1);
    clust1 = clust1(~[clust1=='_']);
    clust2 = cstr(idx:end);
    clust2 = clust2(~[clust2=='_']);
    str(end) = {clust1};
    str(end+1) = {clust2};

    str = [{eyes};{'ratios'};str];

    name = join(str,'_');

    currtab.name(i) = {name};

    clear name str j cstr idx clust1 clust2 str;

  end

  %make output table
  values = currtab.ratio';
  names = currtab.name;
  names = [names{:}];
  tbl = array2table(values,'variablenames',names);

end