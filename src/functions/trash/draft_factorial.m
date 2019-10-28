n = 6;
c = {};
count = 1;
for i = 1:n
for j = 1:n
vals=sort([i,j])
str = sprintf('%d%d',vals(1),vals(2));
c(1,count) = {str};
count = count+1;
end
end
c = unique(c)