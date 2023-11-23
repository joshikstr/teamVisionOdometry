function [bbox]=combine_boxes(bbox)
    a=1;
    while a<=height(bbox)
        PM=[bbox(a,1)+bbox(a,3)/2,bbox(a,2)+bbox(a,4)/2];
        b=1;
        while b<=height(bbox)
            PM2=[bbox(b,1)+bbox(b,3)/2,bbox(b,2)+bbox(b,4)/2];
            Abstand=abs(PM-PM2);
            if a~=b && Abstand(1)<2*bbox(a,3) && Abstand(2)<2*bbox(a,4)
                Lon=[min(bbox(a,1),bbox(b,1)),min(bbox(a,2),bbox(b,2))];
                Run=[max(bbox(a,1)+bbox(a,3),bbox(b,1)+bbox(b,3)),max(bbox(a,2)+bbox(a,4),bbox(b,2)+bbox(b,4))];
                bbox(a,1)=Lon(1);
                bbox(a,2)=Lon(2);
                bbox(a,3)=Run(1)-Lon(1);
                bbox(a,4)=Run(2)-Lon(2);
                bbox(b,:)=[];
                b=b-1;
                if b<a
                    a=a-1;
                end
            end
            b=b+1;
        end
        a=a+1;
    end
end

