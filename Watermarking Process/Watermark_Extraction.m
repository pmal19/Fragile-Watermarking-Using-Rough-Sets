function Watermark_Extraction=extracting
clear;
clc;
conn = database('ionosphere watermarked data','','') %Connect to database
if (~isconnection(conn))            %Error handling
str=conn.Message
h=errordlg(str,'Error','modal' );
while ishandle(h)
      pause(.25)
      end
      error(str)
end

curs=exec(conn, 'select * from "ionosphere watermarked data$"'); %Connect to sheet of the database
setdbprefs('DataReturnFormat','numeric');       %Set preference of return type to numeric
curs=fetch(curs);
a=curs.Data;        %Get the whole table in 'a'
[m,n]=size(a);
display(m);
display(n);

indexLSB=zeros(1,m);
tupleselected=zeros(1,m);
nointegerbits=8;
nofractionbits=8;
alpha=8;
gamma=2;
key=10;


for i=1:m
    b=a(i,:);
    for fe=1:n-1
        d2b = fix(rem(b(fe)*pow2(-(nointegerbits-1):nofractionbits),2));
        p=num2str(d2b(1:4));       
        q=regexprep(p,'[^\w'']','');
        b(fe)=bin2dec(q);
    end
    b(n)=key;
    c=num2str(b);       
    d=regexprep(c,'[^\w'']','');    
    h=hash(d,'MD5');    
    h1=hex2num(h(1:10));
    h2=hex2num(h(10:20));
    indexLSB(i)=floor(mod(h1,alpha))+1;
    if floor(mod(h2,gamma))==0
        tupleselected(i)=1;
    end
end

extracted=zeros(1,128);
count=128;

for i=1:m
    if (tupleselected(i)==1)&(count>0)
        x=a(i,indexLSB(i));
        d2b = fix(rem(x*pow2(-(nointegerbits-1):nofractionbits),2));
        extracted(count)=d2b(nointegerbits);
        extracted(count-1)=d2b(nointegerbits-1);
        count=count-2;
    end    
end

binary=extracted;

count=0;
j=1;

while count<128
sum=0;
for i=1:4
    sum=sum+binary(4+count-i+1)*power(2,i-1);
end

if sum==0
    c(j)='0';
elseif sum==1
    c(j)='1';
elseif sum==2
    c(j)='2';
elseif sum==3
    c(j)='3';
elseif sum==4
    c(j)='4';
elseif sum==5
    c(j)='5';
elseif sum==6
    c(j)='6';
elseif sum==7
    c(j)='7';
elseif sum==8
    c(j)='8';
elseif sum==9
    c(j)='9';
elseif sum==10
    c(j)='a';
elseif sum==11
    c(j)='b';
elseif sum==12
    c(j)='c';
elseif sum==13
    c(j)='d';
elseif sum==14
    c(j)='e';
elseif sum==15
    c(j)='f';
end

sum;

j=j+1;
count=count+4;
end

%d=c(1);
%for i=1:13
%    c(i)=c(i+1);
%end
%c(14)=d;

watermarkextracted=c

close(conn);
close(curs);

end