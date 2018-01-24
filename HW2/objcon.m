    function [f, c, ceq] = objcon(x)
        % extract design variables
        vel = x(1); % ft/s
        pipeDiam = x(2); % ft
        partSize = x(3); % ft

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
        c = zeros(2, 1);
        c(1) = -vel + critVel .* 1.1;
        c(2) = volCons - 0.4;

        % equality constraints
        ceq = [];


    end
