function Watermark_Creation_And_Embedding=watermarking
clear;
clc;
conn = database('ionosphere','','') %Connect to database
if (~isconnection(conn))            %Error handling
str=conn.Message
h=errordlg(str,'Error','modal' );
while ishandle(h)
      pause(.25)
      end
      error(str)
end

curs=exec(conn, 'select * from "ionosphere$"'); %Connect to sheet of the database
setdbprefs('DataReturnFormat','numeric');       %Set preference of return type to numeric
curs=fetch(curs);
a=curs.Data;        %Get the whole table in 'a'
[m,n]=size(a);
display(m);
display(n);
alpha=8;
gamma=2;
key=10;

indexLSB=zeros(1,m);
tupleselected=zeros(1,m);
nointegerbits=8;
nofractionbits=8;


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

for i=1:m
    if tupleselected(i)==1
        b=a(i,indexLSB(i));
        d2b = fix(rem(b*pow2(-(nointegerbits-1):nofractionbits),2));
        d2b(nointegerbits)=0;
        d2b(nointegerbits-1)=0;
        b2d = d2b*pow2(nointegerbits-1:-1:-(nofractionbits)).'; 
        a(i,indexLSB(i))=b2d;
    end
end

filename='ionosphere after removing LSB.xlsx';
sheet='ionosphere after removing LSB';
x1Range='A2';
xlswrite(filename,a,sheet,x1Range);

close(conn);
close(curs);
%-----------------------------------------------------------


conn = database('ionosphere reducts','','') %Connect to database
if (~isconnection(conn))            %Error handling
str=conn.Message
h=errordlg(str,'Error','modal' );
while ishandle(h)
      pause(.25)
      end
      error(str)
end

curs=exec(conn, 'select * from "ionosphere reducts$"'); %Connect to sheet of the database
setdbprefs('DataReturnFormat','numeric');       %Set preference of return type to numeric
curs=fetch(curs);
a =curs.Data;        %Get the whole table in 'a'
[m,n]=size(a);
display(m);
display(n);
reducts=zeros(1,m);
[num, txt, raw] = xlsread('ionosphere reducts.xlsx',1);


for i=2:m+1
    red=[raw{i,1}];
    supportlength=cell2mat(raw(i,[2 3]));
    sp=num2str(supportlength);
    x=strcat(sp,red);
    y=regexprep(x,'[^\w'']','');
    z=hash(y,'MD5');
    reducts(i)=hex2num(z);
end

watermarkreducts=hash(regexprep(num2str(reducts),'[^\w'']',''),'MD5')
    

close(conn);
close(curs);
%-----------------------------------------------------------

conn = database('ionosphere rules','','') %Connect to database
if (~isconnection(conn))            %Error handling
str=conn.Message
h=errordlg(str,'Error','modal' );
while ishandle(h)
      pause(.25)
      end
      error(str)
end

curs=exec(conn, 'select * from "ionosphere rules$"'); %Connect to sheet of the database
setdbprefs('DataReturnFormat','numeric');       %Set preference of return type to numeric
curs=fetch(curs);
a =curs.Data;        %Get the whole table in 'a'
[m,n]=size(a);
display(m);
display(n);
rules=zeros(1,m);
[num, txt, raw] = xlsread('ionosphere rules.xlsx',1);


for i=2:m+1
    rl=[raw{i,1}];
    RHSsupport=cell2mat(raw(i,2));
    sp=num2str(supportlength);
    x=strcat(sp,red);
    y=regexprep(x,'[^\w'']','');
    z=hash(y,'MD5');
    rules(i)=hex2num(z);
end

watermarkrules=hash(regexprep(num2str(rules),'[^\w'']',''),'MD5')

finalwatermark=hash(regexprep(strcat(watermarkreducts,watermarkrules),'[^\w'']',''),'MD5')

close(conn);
close(curs);
%-----------------------------------------------------------

%ax=dec2bin(hex2dec(finalwatermark(1:13)))
%bx=dec2bin(hex2dec(finalwatermark(14:27)))
%cx=dec2bin(hex2dec(finalwatermark(28:32)))

%final=strcat(ax,bx,cx);
%final = final(:)'-'0'

h=finalwatermark;
binary=zeros(1,128);
i=1;

for k=1:32
c=h(k);
i=4*(k-1)+1;
if c=='f'
    binary(i)=1;
    binary(i+1)=1;
    binary(i+2)=1;
    binary(i+3)=1;
elseif c=='e'
    binary(i)=1;
    binary(i+1)=1;
    binary(i+2)=1;
    binary(i+3)=0;
elseif c=='d'
    binary(i)=1;
    binary(i+1)=1;
    binary(i+2)=0;
    binary(i+3)=1;
elseif c=='c'
    binary(i)=1;
    binary(i+1)=1;
    binary(i+2)=0;
    binary(i+3)=0;
elseif c=='b'
    binary(i)=1;
    binary(i+1)=0;
    binary(i+2)=1;
    binary(i+3)=1;
elseif c=='a'
    binary(i)=1;
    binary(i+1)=0;
    binary(i+2)=1;
    binary(i+3)=0;
elseif c=='9'
    binary(i)=1;
    binary(i+1)=0;
    binary(i+2)=0;
    binary(i+3)=1;
elseif c=='8'
    binary(i)=1;
    binary(i+1)=0;
    binary(i+2)=0;
    binary(i+3)=0;
elseif c=='7'
    binary(i)=0;
    binary(i+1)=1;
    binary(i+2)=1;
    binary(i+3)=1;
elseif c=='6'
    binary(i)=0;
    binary(i+1)=1;
    binary(i+2)=1;
    binary(i+3)=0;
elseif c=='5'
    binary(i)=0;
    binary(i+1)=1;
    binary(i+2)=0;
    binary(i+3)=1;
elseif c=='4'
    binary(i)=0;
    binary(i+1)=1;
    binary(i+2)=0;
    binary(i+3)=0;
elseif c=='3'
    binary(i)=0;
    binary(i+1)=0;
    binary(i+2)=1;
    binary(i+3)=1;
elseif c=='2'
    binary(i)=0;
    binary(i+1)=0;
    binary(i+2)=1;
    binary(i+3)=0;
elseif c=='1'
    binary(i)=0;
    binary(i+1)=0;
    binary(i+2)=0;
    binary(i+3)=1;
elseif c=='0'
    binary(i)=0;
    binary(i+1)=0;
    binary(i+2)=0;
    binary(i+3)=0;

end

end

final=binary;

%-----------------------------------------------------------


conn = database('ionosphere after removing LSB','','') %Connect to database
if (~isconnection(conn))            %Error handling
str=conn.Message
h=errordlg(str,'Error','modal' );
while ishandle(h)
      pause(.25)
      end
      error(str)
end

curs=exec(conn, 'select * from "ionosphere after removing LSB$"'); %Connect to sheet of the database
setdbprefs('DataReturnFormat','numeric');       %Set preference of return type to numeric
curs=fetch(curs);
a =curs.Data;        %Get the whole table in 'a'
[m,n]=size(a);
display(m);
display(n);

count=size(final);
i=1;
nointegerbits=8;
nofractionbits=8;

while ((i<=m)&(count>0))
    if tupleselected(i)==1
        b=a(i,indexLSB(i));
        d2b = fix(rem(b*pow2(-(nointegerbits-1):nofractionbits),2));
        d2b(nointegerbits)=final(count(2));
        d2b(nointegerbits-1)=final(count(2)-1);
        count(2)=count(2)-2;
        b2d = d2b*pow2(nointegerbits-1:-1:-(nofractionbits)).'; 
        a(i,indexLSB(i))=b2d;
    end
    i=i+1;
end

filename='ionosphere watermarked data.xlsx';
sheet='ionosphere watermarked data';
x1Range='A2';
xlswrite(filename,a,sheet,x1Range);

extraction_data=[tupleselected.' indexLSB.'];
filename='ionosphere watermarked data.xlsx';
sheet='extraction data';
x1Range='A2';
xlswrite(filename,extraction_data,sheet,x1Range);

finalwatermark

close(conn);
close(curs);

%-----------------------------------------------------------

end