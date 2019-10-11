% gets fields out of a structure
function X = getStruct(Structure,structchain) 

strch = ['x.' structchain];
X = cell2mat(arrayfun(@(x) eval(strch), Structure,'UniformOutput',0));

end