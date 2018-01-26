% extract design variables
vel = 7.2599; % ft/s
[partSize, pipeDiam] = meshgrid(0.0004:0.001:0.01, 0.01:0.001:0.5);

% constants
pipeLen = 15 .* 5280; % ft
wLime = 12.67; % lbm/s
partSizePre = 0.01; % ft
grav = 32.17; % ft/s^2
rhoWater = 62.4; % lbm/ft^3
rhoLime = 168.5; % lbm/ft^3
SGLime = rhoLime ./ rhoWater;
muWater = 0.0007392; %lbm/(ft-sec)
hrPerDay = 8;
dayPerYear = 300;
yrsLife = 7;

% calculate other design variables
volFlow = pi .* (pipeDiam.^2 ./ 4) .* vel;
volFlowLime = wLime ./ rhoLime;
volFlowWater = volFlow - volFlowLime;
volCons = volFlowLime ./ volFlow;
rhoSlurry = rhoWater + volCons .* (rhoLime - rhoWater);

% analysis functions
cdrp = 4 .* grav .* rhoWater .* partSize.^3 .* ((rhoLime - rhoWater) ...
    ./ (3 .* muWater.^2));
% cd = 1.9116946 + 571.81334 .* (1/cdrp);
cd = exp(-.001.*log(cdrp).^3+.0583.*log(cdrp).^2-1.1497.*log(cdrp)+6.4442);
reynolds = (rhoWater .* vel .* pipeDiam) ./ muWater;
critVel = ((40 .* grav .* volCons .* (SGLime - 1) .* pipeDiam) ...
    ./ sqrt(cd)).^0.5;

if reynolds <= 100000
  fricWater = 0.3164 ./ reynolds.^0.25;
else
  fricWater = 0.0032 + 0.221 .* reynolds.^-0.237;
end

fricFact = fricWater .* ((rhoWater ./ rhoSlurry) + 150 .* volCons .*...
    (rhoWater ./ rhoSlurry) .* ((grav .* pipeDiam .* (SGLime - 1)) ./...
    (vel.^2 .* sqrt(cd))).^1.5);
deltaP = (fricFact .* rhoSlurry .* pipeLen .* vel.^2) ./...
    (pipeDiam .* 2 .* grav);
powerPump = deltaP .* volFlow;
powerGrind = 218 .* wLime .* ((1./sqrt(partSize)) - (1./sqrt(partSizePre)));
hpPump = powerPump ./ 550;
hpGrind = powerGrind ./ 550;

purchaseCost = 300 .* hpGrind + 200 .* hpPump;
yearlyPowerCost = (0.07 .* hpGrind + 0.05 .* hpPump) .* hrPerDay .* dayPerYear;
totPowerCost = yearlyPowerCost .* ((1.07.^yrsLife - 1) ./ (0.07 .* 1.07.^7));
totCost = purchaseCost + totPowerCost;
totHP = hpPump + hpGrind;

% 0bjective function
f = totCost;

% constraints
c1 = -vel + critVel .* 1.1;
c2 = volCons - 0.4;


% constants
pi = 3.14159;
del_0 = 0.4; %(in)
h_0 = 1; %(in)
h_def = h_0 - del_0; %(in)
G = 12000000; %(psi)
sf = 1.5;
se = 45000; %(psi)
Q = 150000; %(psi)
w = 0.18;


fig = figure(1)
[C,h] = contour(partSize, pipeDiam, f, 10 , 'k');
clabel(C,h,'Labelspacing',500);
title('Total Cost Contour Plot');
xlabel('Partical Size(ft)');
ylabel('Pipe Diameter(ft)');
hold on;
y1=get(gca,'ylim');
contour(partSize, pipeDiam, c1, [0, 0], 'b')
contour(partSize, pipeDiam, c2, [0, 0], 'r')
plot([0.0005, 0.0005], y1, 'g')
contour(partSize, pipeDiam, c1, [-1, -1], 'b--')
contour(partSize, pipeDiam, c2, [-.1, -.1], 'r--')
plot([0.0007, 0.0007], y1, 'g--')

plot(0.0005, 0.1816, 'r*', 'linewidth', 6)

legend('Total Cost', 'Critical Velocity Limit', 'Volumetric Concentration Limit',...
      'Partical Size Limit', 'Critical Velocity Feasible Region',...
      'Volumetric Concentration Feasible Region', 'Partical Size Feasible Region',...
      'Optimal Solution', 'Location', 'NorthEast')
  
set(fig,'Units','Inches');
pos = get(fig,'Position');
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(fig, '-dpdf', 'test.pdf');
