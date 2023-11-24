% clear;
% close all;
% 
% %imds=imageDatastore("Daten_Training2\Daten_Training2\");
% imds=imageDatastore("Arena_right_left\Arena_right_left\");
% 
% 
% for i=1:size(imds.Files,1)
%     img=imread(imds.Files{i});
%     tic
%     bboxstruct=detect_dosen(img, true);
%     %detect_DosenV2(img);
%     toc
% end

function [out]=detect_Dosen(img,show)
%Inputs
%img: img to detect
%show: sollen die Boxen angezeigt werden?

%Outputs
%bboxes: boxen um die Dosen
%labels: Dosenart (Cola/Fanta oder Pepsi oder Sprite)
annotatedImage=img;
bboxes=zeros(1,4);
labels=[""];

% 
% img_lab=rgb2lab(img);
% max_luminosity = 120;
% L = img_lab(:,:,1)/max_luminosity;
% img_adapthisteq = img_lab;
% img_adapthisteq(:,:,1) = adapthisteq(L)*max_luminosity;
% img_adapthisteq = lab2rgb(img_adapthisteq);
% img_XYZ = colorspace('RGB->XYZ', img_adapthisteq);


%find Dosen-Segmentierung
%cola=(img_XYZ(:,:,1)<0.16 & img_XYZ(:,:,1)>0.01 & img_XYZ(:,:,2)<0.15 & img_XYZ(:,:,2)>0.01 & img_XYZ(:,:,3)<0.01 & img_XYZ(:,:,3)>-0.1 & img(:,:,1)-img(:,:,2)>25)|(img(:,:,1)>100 & img(:,:,2)<70 & img(:,:,3)<40);
%cola=img(:,:,1)>90 & img(:,:,2)<70 & img(:,:,3)<40;
cola=img(:,:,1)./img(:,:,2)>1.5 & img(:,:,1)./img(:,:,3)>3 & img(:,:,1)>50;
Pepsi=img(:,:,3)-img(:,:,1)>10 & img(:,:,3)-img(:,:,2)>10 & img(:,:,3)+img(:,:,1)+img(:,:,2)<150;
%Sprite=img(:,:,1)<30 & img(:,:,2)-img(:,:,3)>10 & img(:,:,2)-img(:,:,3)<40;
Sprite=img(:,:,2)>1.2*img(:,:,1) & img(:,:,2)>img(:,:,3) &img(:,:,2)>50;


Colorspaces=zeros(size(cola,1),size(cola,2),3);
Colorspaces(:,:,1)=cola;
Colorspaces(:,:,2)=Pepsi;
Colorspaces(:,:,3)=Sprite;
name=["",""];
name(1)="ColaoderFanta";
name(2)="Pepsi";
name(3)="Sprite";
out=struct("a",[]);
for color=1:3

    use=Colorspaces(:,:,color);

    %Bereich Glätten
%     Kernel_size=5;
%      max_thresh=(Kernel_size^2)/4;
%      min_thresh=Kernel_size;
%     for a=Kernel_size/2+1:size(use,1)-Kernel_size/2
%         for b=Kernel_size/2+1:size(use,2)-Kernel_size/2
%             s=sum(sum(use(a-Kernel_size/2:a+Kernel_size/2,b-Kernel_size/2:b+Kernel_size/2)));
%             if s>max_thresh
%                 use(a,b)=1;
%             end
%             if s<min_thresh
%                 use(a,b)=0;
%             end
%         end
%     end
%     K=ones(Kernel_size,Kernel_size);
%     use=iconvolve(use,K);
%     use=use>min_thresh;
    
    %Formabgleich:
    width=size(img,1);
    height=size(img,2);
    Dosen=zeros(width,height);
    bbox=zeros(1,4);
    Dosennum=0;
    thresh=20;
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
            else
                use(a,b)=0;
            end

        end
    end
    

    %Nahe Boxen verschmelzen

    
    bbox=combine_boxes(bbox);

    center = bbox(:,2)+bbox(:,4)/2;
    %bbox=bbox(center>290&center<410,:);
    %Form Sicherstellen
    bbox=bbox(bbox(:,3)>15,:);
%     f1=(720-bbox(:,2))./bbox(:,3);
%     bbox=bbox(f1>2,:);
     if color==2||1
         bbox=bbox(bbox(:,4)./bbox(:,3)>1,:);
         
     end
    %Anzeige und Rückgabe vorbereiten
    if show
    annotatedImage = insertObjectAnnotation(annotatedImage,"rectangle",bbox,name(color),LineWidth=4,FontSize=24);
    end
     bboxes=[bboxes;bbox];
     for vknd=1:size(bbox,1)
     labels=[labels;name(color)];
     end
end
if show
imshow(annotatedImage);
end
% bboxes=bboxes(2:end,:);
% labels=labels(2:end);
out=struct(name(1),bboxes(labels==name(1),:),name(2),bboxes(labels==name(2),:),name(3),bboxes(labels==name(3),:));
end