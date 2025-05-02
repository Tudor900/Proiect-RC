global tx
global rx_list  % Changed from rx to rx_list to store multiple receivers
global rtpm
global viewer
global prop_methods
global building_materials
global terrain_materials
global weather_check
global results_box
global lat lon height power freq
global tx rx_list rtpm viewer 
global prop_methods building_materials terrain_materials weather_check
global results_box lat lon height power freq

main_menu = uifigure("Name","Urban Channel Link Analysis", "Position", [100 100 600 600]);

% Transmitter Section
uilabel(main_menu, "Text", "Transmitter Configuration", "Position", [20 550 150 20], "FontWeight", "bold");

lat_lable = uilabel(main_menu, "Text", "Latitude", "Position", [20 520 100 20]);
lat = uieditfield(main_menu, "numeric", "Position", [20 500 200 20], "Value", 44.433396);
lon_lable = uilabel(main_menu, "Text", "Longitude", "Position", [20 480 100 20]);
lon = uieditfield(main_menu, "numeric", "Position", [20 460 200 20], "Value", 26.055370);
height_lable = uilabel(main_menu, "Text", "Height (m)", "Position", [20 440 100 20]);
height = uieditfield(main_menu, "numeric", "Position", [20 420 200 20], "Value", 30);
power_lable = uilabel(main_menu, "Text", "Power (W)", "Position", [20 400 100 20]);
power = uieditfield(main_menu, "numeric", "Position", [20 380 200 20], "Value", 5);
freq_lable = uilabel(main_menu, "Text", "Frequency (Hz)", "Position", [20 360 100 20]);
freq = uieditfield(main_menu, "numeric", "Position", [20 340 200 20], "Value", 28e9);

uibutton(main_menu, "Text", "Show Tx", "ButtonPushedFcn", @(btn,event) showTx(), "Position", [20 300 90 30]);

% Receiver Section
uilabel(main_menu, "Text", "Receiver Configuration", "Position", [20 270 150 20], "FontWeight", "bold");

% Add fields for receiver coordinates
rx_lat_label = uilabel(main_menu, "Text", "Rx Latitude", "Position", [20 250 100 20]);
rx_lat = uieditfield(main_menu, "numeric", "Position", [20 230 200 20], "Value", 44.433396);
rx_lon_label = uilabel(main_menu, "Text", "Rx Longitude", "Position", [20 210 100 20]);
rx_lon = uieditfield(main_menu, "numeric", "Position", [20 190 200 20], "Value", 26.055370);

% Add buttons for receiver management
uibutton(main_menu, "Text", "Add Receiver", "ButtonPushedFcn", @(btn,event) addReceiver(rx_lat.Value, rx_lon.Value), "Position", [20 160 90 30]);
uibutton(main_menu, "Text", "Clear", "ButtonPushedFcn", @(btn,event) clearReceivers(), "Position", [120 160 90 30]);
uibutton(main_menu, "Text", "Show All Rx", "ButtonPushedFcn", @(btn,event) showAllRx(), "Position", [20 120 90 30]);

% Propagation Section
uilabel(main_menu, "Text", "Propagation Configuration", "Position", [240 550 150 20], "FontWeight", "bold");

% Materials dropdowns
uilabel(main_menu, "Text", "Building Material:", "Position", [240 520 100 20]);
building_materials = uidropdown(main_menu, "Items", ["perfect-reflector", "concrete", "brick", "marble",], ...
    "Position", [350 520 150 20], "Value", "perfect-reflector");

uilabel(main_menu, "Text", "Terrain Material:", "Position", [240 490 100 20]);
terrain_materials = uidropdown(main_menu, "Items", ["perfect-reflector", "concrete", "marble", "vegetation", "water"], ...
    "Position", [350 490 150 20], "Value", "perfect-reflector");

% Propagation method dropdown
uilabel(main_menu, "Text", "Propagation Method:", "Position", [240 460 100 20]);
prop_methods = uidropdown(main_menu, "Items", ["Free Space", "Ray Tracing (LOS)", "Ray Tracing (1 Reflection)", "Ray Tracing (2 Reflections)", "Ray Tracing (1 Diffraction)"], ...
    "ItemsData", [1 2 3 4 5], "Position", [350 460 150 20], "Value", 2);

% Weather effects checkbox
weather_check = uicheckbox(main_menu, "Text", "Include Weather Effects", "Position", [240 430 150 20]);

% Analysis buttons
uibutton(main_menu, "Text", "Line of Sight", "ButtonPushedFcn", @(btn,event) losTxRx(), "Position", [240 390 120 30]);
uibutton(main_menu, "Text", "Show Coverage", "Position", [240 350 120 30], "ButtonPushedFcn", @(btn, event) showCoverage());
uibutton(main_menu, "Text", "Raytrace All", "Position", [240 310 120 30], "ButtonPushedFcn", @(btn, event) raytraceAllPaths());
uibutton(main_menu, "Text", "Analyze All", "Position", [240 270 120 30], "ButtonPushedFcn", @(btn, event) analyzeAllSignals());

% Results display
results_box = uitextarea(main_menu, "Position", [20 20 560 80], "Value", "Results will appear here...");

% Initialize viewer and receiver list
viewer = siteviewer(Buildings="map(1).osm", Basemap="topographic");
rx_list = {}; % Initialize empty cell array for receivers

% Helper functions
function showTx()
    global tx viewer height power freq
    
    tx = txsite(Name="Small cell transmitter", ...
        Latitude=44.434031, ...
        Longitude=26.055325, ...
        AntennaHeight=height.Value, ...
        TransmitterPower=power.Value, ...
        TransmitterFrequency=freq.Value);
    show(tx)
end

function addReceiver(lat, lon)
    global rx_list viewer
    
    % Create unique name for receiver
    rx_name = sprintf("Receiver %d", length(rx_list)+1);
    
    % Create and store receiver
    new_rx = rxsite("Name", rx_name,...
          "Latitude", lat,...
          "Longitude", lon,...
          "AntennaHeight", 1);
    
    rx_list{end+1} = new_rx;
    show(new_rx)
    
    % Update results box
    updateResults(sprintf("Added %s at (%.6f, %.6f)", rx_name, lat, lon));
end

function clearReceivers()
    global rx_list viewer
    
    clearMap(viewer)
    rx_list = {};
    updateResults("All receivers cleared");
end

function showAllRx()
    global rx_list viewer
    
    if isempty(rx_list)
        updateResults("No receivers to show");
        return;
    end
    
    clearMap(viewer)
    for i = 1:length(rx_list)
        show(rx_list{i});
    end
    updateResults(sprintf("Displayed %d receivers", length(rx_list)));
end

function losTxRx()
    global tx rx_list viewer
    
    if isempty(tx) || isempty(rx_list)
        updateResults('Please create transmitter and at least one receiver first');
        return;
    end
    
    for i = 1:length(rx_list)
        los(tx, rx_list{i});
    end
end

function updatePropagationModel()
    global rtpm prop_methods building_materials terrain_materials weather_check
    
    method_val = prop_methods.Value;
    
    switch method_val
        case 1 % Free Space
            rtpm = propagationModel("freespace");
            
        case 2 % Ray Tracing LOS
            rtpm = propagationModel("raytracing", ...
                "Method", "sbr", ...
                "MaxNumReflections", 0, ...
                "MaxNumDiffractions", 0, ...
                "BuildingsMaterial", building_materials.Value, ...
                "TerrainMaterial", terrain_materials.Value);
                
        case 3 % 1 Reflection
            rtpm = propagationModel("raytracing", ...
                "Method", "sbr", ...
                "MaxNumReflections", 1, ...
                "MaxNumDiffractions", 0, ...
                "BuildingsMaterial", building_materials.Value, ...
                "TerrainMaterial", terrain_materials.Value);
                
        case 4 % 2 Reflections
            rtpm = propagationModel("raytracing", ...
                "Method", "sbr", ...
                "MaxNumReflections", 2, ...
                "MaxNumDiffractions", 0, ...
                "BuildingsMaterial", building_materials.Value, ...
                "TerrainMaterial", terrain_materials.Value);
                
        case 5 % 1 Diffraction
            rtpm = propagationModel("raytracing", ...
                "Method", "sbr", ...
                "MaxNumReflections", 0, ...
                "MaxNumDiffractions", 1, ...
                "BuildingsMaterial", building_materials.Value, ...
                "TerrainMaterial", terrain_materials.Value);
    end
    
    % Add weather effects if selected
    if weather_check.Value
        rtpm = rtpm + propagationModel("gas") + propagationModel("rain");
    end
end

function showCoverage()
    global tx rtpm viewer rx_list
    
    if isempty(tx)
        updateResults('Please create transmitter first');
        return;
    end
    
    updatePropagationModel();
    
    clearMap(viewer);
    show(tx);
    
    % Show coverage area from transmitter
    coverage(tx, rtpm, ...
        "SignalStrengths", -120:-5, ...
        "MaxRange", 250, ...
        "Resolution", 3, ...
        "Transparency", 0.6);
    
    % Show all receivers if any exist
    if ~isempty(rx_list)
        for i = 1:length(rx_list)
            show(rx_list{i});
        end
        updateResults(sprintf("Displayed coverage area with %d receivers", length(rx_list)));
    else
        updateResults("Displayed coverage area (no receivers)");
    end
end

function raytraceAllPaths()
    global tx rx_list rtpm viewer results_box path_colors
    
    if isempty(tx)
        updateResults('Please create transmitter first');
        return;
    end
    
    if isempty(rx_list)
        updateResults('Please add at least one receiver first');
        return;
    end
    
    % Update propagation model based on current settings
    updatePropagationModel();
    
    % Clear map and show transmitter
    clearMap(viewer);
    show(tx);
    
    % Initialize results text
    results_text = "Ray Tracing Results:\n";
    
    % Perform raytracing for each receiver
    for i = 1:length(rx_list)
        rx = rx_list{i};
        show(rx);
        
        % Perform raytracing
        rays = raytrace(tx, rx, rtpm);
        
        % Calculate signal strength
        ss = sigstrength(rx, tx, rtpm);
        
        % Add to results
        results_text = results_text + sprintf("\n%s:\n", rx.Name);
        results_text = results_text + sprintf("  Position: (%.6f, %.6f)\n", rx.Latitude, rx.Longitude);
        results_text = results_text + sprintf("  Signal Strength: %.2f dBm\n", ss);
        
        % Add path information if rays were found
        if ~isempty(rays{1})
            num_paths = length(rays{1});
            results_text = results_text + sprintf("  Number of paths: %d\n", num_paths);
            
            for j = 1:num_paths
                path = rays{1}(j);
                results_text = results_text + sprintf("  Path %d: ", j);
                
                % Initialize counters
                reflection_count = 0;
                diffraction_count = 0;
                
                % Check interactions
                if isfield(path, 'Interactions') && ~isempty(path.Interactions)
                    for k = 1:length(path.Interactions)
                        if isfield(path.Interactions(k), 'Type')
                            % Newer version format
                            if strcmp(path.Interactions(k).Type, 'Reflection')
                                reflection_count = reflection_count + 1;
                            elseif strcmp(path.Interactions(k).Type, 'Diffraction')
                                diffraction_count = diffraction_count + 1;
                            end
                        else
                            % Older version format
                            if isfield(path.Interactions(k), 'Reflection')
                                reflection_count = reflection_count + path.Interactions(k).Reflection;
                            end
                            if isfield(path.Interactions(k), 'Diffraction')
                                diffraction_count = diffraction_count + path.Interactions(k).Diffraction;
                            end
                        end
                    end
                end
                
                % Build results string
                if reflection_count > 0
                    results_text = results_text + sprintf("%d reflection(s) ", reflection_count);
                end
                
                if diffraction_count > 0
                    results_text = results_text + sprintf("%d diffraction(s) ", diffraction_count);
                end
                
                if reflection_count == 0 && diffraction_count == 0
                    results_text = results_text + "LOS path";
                end
                
                results_text = results_text + "\n";
                
                % Visualize path with appropriate color
                if isstruct(path_colors) % Double-check path_colors is a struct
                    if diffraction_count > 0
                        plot(path, 'Color', path_colors.Diffraction);
                    elseif reflection_count > 0
                        plot(path, 'Color', path_colors.Reflection);
                    else
                        plot(path, 'Color', path_colors.LOS);
                    end
                else
                    plot(path); % Default color if path_colors isn't available
                end
            end
        else
            results_text = results_text + "  No valid paths found\n";
        end
    end
    
    % Update results display
    results_box.Value = results_text;
end

function analyzeAllSignals()
    global tx rx_list rtpm results_box prop_methods building_materials terrain_materials weather_check
    
    if isempty(tx) || isempty(rx_list)
        results_box.Value = "Please create transmitter and at least one receiver first";
        return;
    end
    
    updatePropagationModel();
    
    % Get current configuration
    method_names = ["Free Space", "Ray Tracing (LOS)", "Ray Tracing (1 Reflection)", ...
                   "Ray Tracing (2 Reflections)", "Ray Tracing (1 Diffraction)"];
    method_name = method_names(prop_methods.Value);
    
    config_text = sprintf("Current Configuration:\n");
    config_text = config_text + sprintf("  Method: %s\n", method_name);
    config_text = config_text + sprintf("  Building Material: %s\n", building_materials.Value);
    config_text = config_text + sprintf("  Terrain Material: %s\n", terrain_materials.Value);
    config_text = config_text + sprintf("  Weather Effects: %s\n", string(weather_check.Value));
    
    results_text = config_text + "\nSignal Analysis Results:\n";
    
    % Calculate signal strength for each receiver
    for i = 1:length(rx_list)
        ss = sigstrength(rx_list{i}, tx, rtpm);
        results_text = results_text + sprintf("  %s: %.2f dBm\n", rx_list{i}.Name, ss);
    end
    
    results_box.Value = results_text;
end

function updateResults(message)
    global results_box
    results_box.Value = message;
end
