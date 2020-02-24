function v1=nansub2ind(siz,v1,v2)

v1(v1<1|v1>siz(1))=nan;
v2(v2<1|v2>siz(2))=nan;

v1=v1+(v2-1).*siz(1);