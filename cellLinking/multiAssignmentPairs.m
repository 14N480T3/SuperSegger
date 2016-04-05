function [assignments,errorR]  = multiAssignmentPairs (data_c, data_f,CONST, forward, debug_flag)
% each row is assigned to one column only - starting by the minimum
% possible cost and continuing to the next minimum possible cost.
% works only c - > f (r -> c) not backwards. attempts to map candidates to
% one or two cells, but not the other way around.

if ~exist('debug_flag','var') || isempty(debug_flag)
    debug_flag = 0;
end

if ~exist('forward','var') || isempty(forward)
    forward = 1;
end

assignments = [];
errorR = [];


if ~isempty(data_c)
    if ~isfield(data_c,'regs')
        data_c = updateRegionFields (data_c,CONST);
    end
    
    numRegs1 = data_c.regs.num_regs;
    assignments  = cell( 1, numRegs1);
    errorR = zeros(1,numRegs1);
    
    if ~isempty(data_f)
        if ~isfield(data_f,'regs')
            data_f = updateRegionFields (data_f,CONST);
        end
        
        areaFactor = 10;
        areaChangeFactor = 100;
        
        numRegs2 = data_f.regs.num_regs;
        regsInC = 1:data_c.regs.num_regs;
        regsInF = 1:data_f.regs.num_regs;
        
        idsC(1,regsInC) = regsInC;
        idsC(2,regsInC) = NaN;
        
        idsF(1,regsInF) = regsInF;
        idsF(2,regsInF) = NaN;
        
        
        % colony calculation
        maskBgFill= imfill(data_c.mask_bg,'holes');
        colony_labels = bwlabel(maskBgFill);
        colony_props = regionprops( colony_labels,'Centroid','Area');
        
        
        
        % find possible pairs....
        counter = 1;
        pairsF = NaN * zeros(2,numRegs2 * numRegs2);
        for jj = regsInF
            maskF = (data_f.regs.regs_label==jj);
            tmp_mask = imdilate(maskF, strel('square',5));
            neigh = data_f.regs.regs_label(tmp_mask);% get neighbors
            ind_neigh = unique(neigh)'; % unique neighbors
            ind_neigh = ind_neigh(ind_neigh > jj); % not already made pairs
            
            % make pairs
            for uu = ind_neigh
                pairsF(:,counter)   = [jj;uu];
                counter = counter + 1;
            end
        end
        
        cleanpairIDs = (nansum(pairsF)~=0);
        pairsF = pairsF(:,cleanpairIDs);
        allF = [idsF,pairsF];
        counter = 1;
        pairsC = NaN * zeros(2,numRegs2 * numRegs2);
        
        for jj = regsInC            
            maskC = (data_c.regs.regs_label==jj);
            % get neighbors
            tmp_mask = imdilate(maskC, strel('square',5));
            neigh = data_c.regs.regs_label(tmp_mask);
            ind_neigh = unique(neigh)'; % unique neighbors
            ind_neigh = ind_neigh(ind_neigh > jj); % not already made pairs
            
            % make pairs
            for uu = ind_neigh
                pairsC(:,counter) = [jj;uu];
                counter = counter + 1;
            end
        end
        
        pairsC = pairsC(:,(nansum(pairsC)~=0));
        allC = [idsC,pairsC];
        
        
        areaOverlapCost = NaN * ones(size(allC,2),size(allF,2));
        areaChange = NaN * ones(size(allC,2),size(allF,2));
        centroidCost = NaN * ones(size(allC,2),size(allF,2));
        areaOverlapTransCost = NaN * ones(size(allC,2),size(allF,2));
        outwardMot = NaN * ones(size(allC,2),size(allF,2));
        areaChangePenalty =  zeros(size(allC,2),size(allF,2));
        % one to one mapping
        goodOneToOne = zeros(1,size(allC,2));
        
        for ii = 1:size(allC,2) % loop through the regions
            % ind : list of regions that overlap with region ii in data 1
            
            % if it already has a good mapping don't bother..
            
            cRegs = allC(:,ii);
            isSingleRegC = sum(isnan(cRegs)); % has a nan
            
            % to skip pairs for which one of the regions already has a good
            % ... mapping
            alreadyFoundOneToOne = ~isSingleRegC  && (goodOneToOne(cRegs(1)) ...
                || goodOneToOne(cRegs(2))) ;
            
            
            % check if region is still around
            if isSingleRegC
                regionExists = sum(data_c.regs.regs_label(:) == cRegs(1));
            else
                regionExists = sum(data_c.regs.regs_label(:) == cRegs(1)) &&...
                sum(data_c.regs.regs_label(:) == cRegs(2));
            end
            if  ~alreadyFoundOneToOne && regionExists
                
                [maskC,areaC,centroidC] = regProperties (data_c,cRegs);
                
                
                % colony it belongs to
                colonyId =  max(colony_labels(maskC));
                distFromColony = centroidC - colony_props(colonyId).Centroid;
                
                % dilate mask and get adjacent regions within dilated area
                tmp_mask = imdilate(maskC, strel('square',5));
                tmpregs2 = data_f.regs.regs_label(tmp_mask);
                possibleMapInd = unique(tmpregs2);
                possibleMapInd = possibleMapInd(possibleMapInd~=0)'; % remove 0
                
                
                % one to one mapping
                
                % calculate masks, areas, centroids
                
                for uu = 1:numel(possibleMapInd)
                    
                    
                    % one to one mapping
                    idF = possibleMapInd(uu);
                    [maskF,areaF,centroidF] = regProperties (data_f,idF);
                    overlapMask = maskF(maskC);
                    areaOverlap = sum(overlapMask(:)); % area of overlap between jj and ii
                    areaOverlapCost(ii,idF) = areaOverlap/areaC;
                    
                    if  (areaOverlapCost(ii,idF) == 0)
                        areaOverlapCost(ii,idF) = 0.001;
                    end
                    
                    displacement = centroidC - centroidF;
                    centroidCost(ii,idF) = sqrt(sum((displacement).^2));
                    outwardMot(ii,idF) = (distFromColony*displacement')/centroidCost(ii,idF);
                    areaChange(ii,idF) = (areaF - areaC)/(areaC);
                    
                    % moved area
                    
                    offset = round(displacement);
                    maskOut = imtranslate(maskF,offset);
                    maskOut = maskOut(maskC);
                    areaOverlapTrns = sum(maskOut(:));
                    areaOverlapTransCost(ii,idF) = areaOverlapTrns/areaC;
                    
                    if (areaOverlapTransCost(ii,idF) == 0)
                        areaOverlapTransCost(ii,idF) = 0.001;
                    end
                    
                    %intDisplay (data_c,data_f,idF,ii)
                    %keyboard;
                    % if the one to one mapping looks good don't bother with
                    % pairs - to make faster
                    
                    
                end
                
                if isSingleRegC % one cell to be mapped
                    totCost(ii,:) = areaChangeFactor * 1./areaOverlapTransCost(ii,:) + ...
                        areaFactor * 1./areaOverlapCost(ii,:) + centroidCost(ii,:) + ...
                        areaChangeFactor * abs(areaChange(ii,:));
                    
                    [cost,indx] = min(totCost(ii,:));
                    
                    goodOneToOne(ii) = abs(areaChange(ii,indx)) < 0.25 &&...
                        areaOverlapCost(ii,indx) > 0.6 ...
                        && areaOverlapTransCost(ii,indx) > 0.7;
                    
                else
                    goodOneToOne (ii) = 1; % no two to two mappings
                end
                
                
                if ~goodOneToOne(ii)
                    for uu = 1:numel(possibleMapInd)
                        for kk = (uu+1) : numel(possibleMapInd)
                            
                            sis(1) = possibleMapInd(uu);
                            sis(2) = possibleMapInd(kk);
                            
                            isItPair = all(ismember(allF,[sis(1),sis(2)]));
                            if any(isItPair)
                                % find their location
                                location = find (isItPair);
                                
                                % combined masks, areas, centroids
                                [maskF,areaF,centroidF] = regProperties (data_f,sis);
                                overlapMask = maskF(maskC);
                                areaOverlap = sum(overlapMask(:)); % area of overlap between jj and ii
                                areaOverlapCost(ii,location) = areaOverlap/areaC;
                                
                                if  (areaOverlapCost(ii,location) == 0)
                                    areaOverlapCost(ii,location) = 0.001;
                                end
                                
                                displacement = centroidC - centroidF;
                                centroidCost(ii,location) = sqrt(sum((displacement).^2));
                                outwardMot(ii,location) = (distFromColony*displacement')/centroidCost(ii,location);
                                
                                offset = round(displacement);
                                maskOut = imtranslate(maskF,offset);
                                maskOut = maskOut(maskC);
                                areaOverlapTrns = sum(maskOut(:));
                                areaOverlapTransCost(ii,location) = areaOverlapTrns/areaC;
                                
                                if  (areaOverlapTransCost(ii,location) == 0)
                                    areaOverlapTransCost(ii,location) = 0.001;
                                end
                                
                                
                                areaChange(ii,location) = (areaF - areaC)/(areaC);
                            end
                        end
                    end                    
                end
            end
        end
        
        % delete big area changes
        
        areaChangePenalty(abs(areaChange) > 0.7) = 50;
        if forward
            areaChangePenalty((areaChange) < -0.1) = 100;
        else
            outwardMot = - outwardMot;
            areaChangePenalty((areaChange) > 0.1) = 100;
        end
        totCost = areaChangePenalty + outwardMot + areaChangeFactor * 1./areaOverlapTransCost + areaFactor * 1./areaOverlapCost + centroidCost +  areaChangeFactor * abs(areaChange);
        
        costMat = totCost;
        
        numElements = size(costMat,1);
        assignedInC = [];
        assignedInF = [];
        
        while nansum (costMat(:)) > 0
            [minCost,ind] = min(costMat(:));
            [asgnRow,asgnCol] = ind2sub(size(costMat),ind);
            assignTemp = allF(:,asgnCol)';
            assignTemp = assignTemp (~isnan(assignTemp));
            
            regionsInC = allC (:,asgnRow);
            assignments {regionsInC(1)} = assignTemp;
            
            if ~isnan(regionsInC(2))
                assignments {regionsInC(2)} = assignTemp;
            end
            
            if debug_flag
                intDisplay (data_c,data_f,assignTemp,regionsInC);
                pause;
            end
            
            assignedInC  = [assignedInC;regionsInC'];
            assignedInF = [assignedInF;assignTemp'];
            % find all columns to be set as nans
            colToDelF = any(ismember(allF,assignTemp));
            colToDelC = any(ismember(allC,regionsInC));
            costMat (colToDelC, :) = NaN; % add nans to already assigned
            costMat (:, colToDelF) = NaN; % add nans to already assigned
        end
        
        
        % find leftovers, give them max assignments, and put errors in them..
        leftInC = setdiff (regsInC,assignedInC);
        leftInF = setdiff (regsInF,assignedInF);
        newleftInC = leftInC;
        % fix assignment errors
        % best next assignments for those
        [~,minIndxF] = min(totCost');
        %[~,minIndxC] = min(totCost');
        

        for kk = 1 : numel(leftInC)
            leftC = leftInC(kk);
            bestF = minIndxF(leftC);
            
            for badC = 1 : numel(assignments)
                tempAss = assignments{badC};
                if any(tempAss ==bestF)
                    break
                end
            end
            
            % would second option be good enough?
            totCostTemp = totCost(badC,:);
            costBef = totCostTemp( bestF);
            totCostTemp( bestF) = NaN;
            [cost,badCSecond] = min(totCostTemp);
            
            if any(leftInF == badCSecond)
                assignments{badC} = badCSecond;
                assignments{leftC} = bestF;
                newleftInC = setdiff(newleftInC,leftC);
            end
        end
        
        
        for ii = newleftInC
            errorR (ii) = 1;
        end
        
        %
        %         debug_flag = 0;
        %         if debug_flag
        %             figure(1)
        %             imshow(data_f.phase,[]);
        %             figure(2)
        %             imshow(data_c.phase,[]);
        %
        %             figure(3);
        %             % check out the assignments :)
        %             for uu = 1:data_c.regs.num_regs
        %                 intDisplay (data_c,data_f,assignments{uu},uu)
        %                 pause;
        %             end
        %         end
        %
    end
end
end

function [comboMask,comboArea,comboCentroid] = regProperties (data_c,regNums)
comboCentroid = 0;
comboMask = 0 * (data_c.regs.regs_label);
comboArea = 0;
regNums = regNums(~isnan(regNums));
for ii = 1: numel(regNums)
    reg = regNums(ii);
    comboCentroid = comboCentroid + data_c.regs.props(reg).Centroid;
    comboMask =  comboMask + (data_c.regs.regs_label==reg);
    comboArea = comboArea + data_c.regs.props(reg).Area;
end

comboCentroid = comboCentroid/numel(regNums); % mean centroid
comboMask = (comboMask>0);
end



function intDisplay (data_c,data_f,regF,regC)

maskC = data_c.regs.regs_label*0;
for c = 1 : numel(regC)
    if ~isnan(regC(c))
        maskC = maskC + (data_c.regs.regs_label == regC(c))>0;
    end
end

maskF = data_f.regs.regs_label*0;

if isempty(regF)
    disp('nothing')
    imshow (cat(3,0*ag(maskF),ag(maskC),ag(data_c.mask_cell)));
else
    for f = 1 : numel(regF)
        if ~isnan(regF(f))
            maskF = maskF + (data_f.regs.regs_label == regF(f))>0;
        end
    end
    imshow (cat(3,ag(maskF),ag(maskC),ag(data_c.mask_cell)));
end
end