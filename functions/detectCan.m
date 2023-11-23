function detectedCan=detectCan(img)

annotatedImage=img;
%Kanten erhaltender Gaußfilter
%img_smoth=imbilatfilt(img,50,10);
% figure;
% idisp(img_smoth);


%Kontrast erhöhen
%img_lab=rgb2lab(img_smoth);
%max_luminosity = 120;
%L = img_lab(:,:,1)/max_luminosity;
%img_adapthisteq = img_lab;
%img_adapthisteq(:,:,1) = adapthisteq(L)*max_luminosity;
%img_adapthisteq = lab2rgb(img_adapthisteq);

% img_XYZ = colorspace('RGB->XYZ', img_adapthisteq);
%figure;
%idisp(img_XYZ);


%find Cola Dosen
%cola=img_XYZ(:,:,1)<0.06 & img_XYZ(:,:,1)>0.01 & img_XYZ(:,:,2)<0.05 & img_XYZ(:,:,2)>0.01 & img_XYZ(:,:,3)<0.01 & img_XYZ(:,:,3)>-0.1 & img(:,:,1)-img(:,:,2)>25;
cola=img(:,:,1)>100 & img(:,:,2)<70 & img(:,:,3)<40;
Pepsi=img(:,:,3)-img(:,:,1)>10 & img(:,:,3)-img(:,:,2)>10 & img(:,:,3)+img(:,:,1)+img(:,:,2)<100;
Sprite=img(:,:,1)<30 & img(:,:,2)-img(:,:,3)>10 & img(:,:,2)-img(:,:,3)<40;
Colorspaces=zeros(size(cola,1),size(cola,2),2);
Colorspaces(:,:,1)=cola;
Colorspaces(:,:,2)=Pepsi;
Colorspaces(:,:,3)=Sprite;
name=["",""];
name(1)="Cola_oder_Fanta";
name(2)="Pepsi";
name(3)="Sprite";
for color=1:3
    Kernel_size=10;
    max_thresh=(Kernel_size^2)/2;
    min_thresh=Kernel_size;


    use=Colorspaces(:,:,color);


    for a=Kernel_size/2+1:size(use,1)-Kernel_size/2
        for b=Kernel_size/2+1:size(use,2)-Kernel_size/2
            s=sum(sum(use(a-Kernel_size/2:a+Kernel_size/2,b-Kernel_size/2:b+Kernel_size/2)));
            if s>max_thresh
                use(a,b)=1;
            end
            if s<min_thresh
                use(a,b)=0;
            end
        end
    end
%     I=double(img).*double(use);
%     figure;
%     idisp(I);

    %Form abgleich:
    width=size(img,1);
    height=size(img,2);
    Dosen=zeros(width,height);
    bbox=zeros(1,4);
    Dosennum=0;
    labelstr = cell(1,1);
    thresh=30;
    for a=1:width
        for b=1:height
            c=a;
            falsecount=0;
            while c<width-1
                c=c+1;
                if ~use(c,b)
                    falsecount=falsecount+1;
                else
                    falsecount=0;
                end
                if falsecount>thresh
                    c=c-thresh;
                    break
                end
            end
            falsecount=0;
            d=b;
            while d<height-1
                d=d+1;
                if ~use(a,d)
                    falsecount=falsecount+1;
                else
                    falsecount=0;
                end
                if falsecount>thresh
                    d=d-thresh;
                    break
                end
            end
            form=(c-a)/(d-b);
            if form>3 && form<3.5 && d-b>10 && c-a>10
                use(a:c,b:d)=0;
                Dosennum=Dosennum+1;
                bbox(Dosennum,2)=a;
                bbox(Dosennum,1)=b;
                bbox(Dosennum,4)=c-a;
                bbox(Dosennum,3)=d-b;
                Dosen(a:c,b:d)=1;
                labelstr{Dosennum}="Cola- oder Fantadose";
            else
                use(a,b)=0;
            end

        end
    end

    % I=double(img).*double(Dosen);
    % figure;
    % idisp(uint8(I));

    bbox=combine_boxes(bbox);
    bbox=bbox(bbox(:,3)>15,:);
    %bbox=bbox(bbox(:,4)>40,:);
    %bbox=bbox(bbox(:,4)./bbox(:,3)>2,:);
    if color~=3
        bbox=bbox(bbox(:,4)./bbox(:,3)>2,:);
    end
    annotatedImage = insertObjectAnnotation(annotatedImage,"rectangle",bbox,name(color),LineWidth=4,FontSize=24);
    %figure
    
    detectedCan.(name(color)) = bbox;
end
%figure;
% idisp(annotatedImage);
end
