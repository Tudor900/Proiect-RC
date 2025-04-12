global tx
global rx
global rtpm


main_menu = uifigure("Name","Main Menu");


lat_lable = uilabel(main_menu,"Text", "Latitude", "Position", [20 80 100 20]);
lat = uitextarea(main_menu, "Position",[20 60 200 20],"Value","44.433396");
lon_lable = uilabel(main_menu,"Text", "Longitude", "Position", [20 40 100 20]);
lon = uitextarea(main_menu, "Position",[20 20 200 20], "Value", "26.055370");

uibutton(main_menu, "Text", "Show Rx", "ButtonPushedFcn", @(btn,event) showRx(str2double(lat.Value),str2double(lon.Value)),"Position", [20 100 90 30]);

uibutton(main_menu, "Text", "Show Tx", "ButtonPushedFcn", @(btn,event) showTx(), "Position", [20 140 90 30]);


uibutton(main_menu, "Text", "Line of Sight", "ButtonPushedFcn", @(btn,event) losTxRx(), "Position", [20 180 90 30]);


dd = uidropdown(main_menu, "Items", ["FreeSpace", "RayTracing"], "ItemsData",[1 2] ,"Position", [240 40 100 20]);

uibutton(main_menu, "Text", "Select", "Position", [340 40 100 30], "ButtonPushedFcn", @(btn, event) handleSelection(dd));


uibutton(main_menu, "Text", "Show Tx Coverage", "Position", [20 220 90 30], "ButtonPushedFcn", @(btn, event) showCoverage());



viewer = siteviewer( Buildings="map(1).osm",Basemap="topographic");


function showTx()
    
 global tx

tx = txsite(Name="Small cell transmitter", ...
    Latitude=44.434031, ...
    Longitude=26.055325, ...
    AntennaHeight=30, ...
    TransmitterPower=5, ...
    TransmitterFrequency=28e9);
show(tx)



end

function showRx(lat, lon)

global rx
rx = rxsite("Name", "Receiver",...
      "Latitude",lat,...
      "Longitude",lon,...
      AntennaHeight=1);
show(rx)



end


function losTxRx()
global tx rx


los(tx,rx)

end

function handleSelection(dropdown)

global rtpm
    selected = dropdown.Value;  % This is a number
    disp(['You selected: ', num2str(selected)]);
    
    % Optional: take action based on selection
    switch selected
        case 1
            disp("Not implemented");
        case 2
            rtpm = propagationModel("raytracing", ...
                Method="sbr", ...
                MaxNumReflections=0, ...
                BuildingsMaterial="perfect-reflector", ...
                TerrainMaterial="perfect-reflector");
    end
end

function showCoverage()
global tx
global rtpm

coverage(tx,rtpm, ...
    SignalStrengths=-120:-5, ...
    MaxRange=250, ...
    Resolution=3, ...
    Transparency=0.6)

end
