% temporary hack to remove double triggered spikes

tt=data.tt;

dt = diff(tt.t);
ndx = find(dt < 0.8);
w = cat(3,tt.w{:});
w = sqrt(sum(w.^2,3));
p = reshape(w(9,[ndx, ndx+1]),[],2);

[foo,i] = min(p,[],2);
for j=1:4, tt.w{j}(:,ndx+i-1)=[]; end
