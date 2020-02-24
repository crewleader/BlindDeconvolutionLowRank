function [S,hMRF]=graph_cuts(S,hMRF,Dtau,L,beta,gamma,fsize)

GCO_MAX_ENERGYTERM=10000000;

amplifier=100/min(gamma,beta);

E=Dtau-L;

AdjMatrix=getAdj(fsize);

%% estimate S=~Omega;
if gamma>0
	% graph cuts initialization
	% GCO toolbox is called
	if isempty(hMRF)
		hMRF=GCO_Create(prod(fsize),2);
		GCO_SetSmoothCost(hMRF,[0 1; 1 0]);
		neighbor_cost=round(amplifier*gamma);
		neighbor_cost(neighbor_cost>=GCO_MAX_ENERGYTERM)=GCO_MAX_ENERGYTERM;
		GCO_SetNeighbors(hMRF,neighbor_cost*AdjMatrix);
	end
	
	% call GCO to run graph cuts
	for i=1:size(Dtau,2)
		datacost=int32(amplifier*[beta*ones(size(E,1),1),0.5*(E(:,i)).^2]');
		datacost(datacost>=GCO_MAX_ENERGYTERM)=GCO_MAX_ENERGYTERM;
		GCO_SetDataCost(hMRF,datacost);
		GCO_Expansion(hMRF);
		S(:,i)=(GCO_GetLabeling(hMRF)==1)';
	end
else
	% direct hard thresholding if no smoothness
	S=0.5*E.^2>beta;
end

end

%% function to get the adjcent matirx of the graph
function W=getAdj(sizeData)
numSites=prod(sizeData);
id1=[1:numSites,1:numSites,1:numSites];
id2=[1+1:numSites+1,...
	1+sizeData(1):numSites+sizeData(1),...
	1+sizeData(1)*sizeData(2):numSites+sizeData(1)*sizeData(2)];
value=ones(1,3*numSites);
W=sparse(id1,id2,value);
W=W(1:numSites,1:numSites);
end