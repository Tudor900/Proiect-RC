%Import and Visualize Buildings Data

viewer = siteviewer(Buildings="map(1).osm",Basemap="topographic");

%Define Transmitter Site

tx = txsite(Name="Small cell transmitter", ...
    Latitude=44.434031, ...
    Longitude=26.055325, ...
    AntennaHeight=30, ...
    TransmitterPower=5, ...
    TransmitterFrequency=28e9);
show(tx)

%View Coverage Map for Line-of-Sight Propagation

rtpm = propagationModel("raytracing", ...
    Method="sbr", ...
    MaxNumReflections=0, ...
    BuildingsMaterial="perfect-reflector", ...
    TerrainMaterial="perfect-reflector");

coverage(tx,rtpm, ...
    SignalStrengths=-120:-5, ...
    MaxRange=250, ...
    Resolution=3, ...
    Transparency=0.6)

%Define Receiver Site in Non-Line-of-Sight Location

names = ["Receiver1","Receiver2"];
lats = [44.432485,44.433225];
lons = [26.056508,26.058526];

rxs = rxsite("Name", names,...
      "Latitude",lats,...
      "Longitude",lons,...
      AntennaHeight=1);

los(tx,rxs)

%Plot Propagation Path Using Ray Tracing

rtpm.MaxNumReflections = 1;
clearMap(viewer)
raytrace(tx,rxs,rtpm)

%Analyze Signal Strength and Effect of Materials

ss = sigstrength(rxs,tx,rtpm);
disp("Received power perfect reflection: " + ss + " dBm")

rtpm.BuildingsMaterial = "concrete";
rtpm.TerrainMaterial = "concrete";
raytrace(tx,rxs,rtpm)

ss = sigstrength(rxs,tx,rtpm);
disp("Received power + concrete materials: " + ss + " dBm")

%Include Weather Loss

rtPlusWeather = ...
    rtpm + propagationModel("gas") + propagationModel("rain");
raytrace(tx,rxs,rtPlusWeather)

ss = sigstrength(rxs,tx,rtPlusWeather);
disp("Received power with weather loss: " + ss + " dBm")

%Plot Propagation Paths Including Two Reflections

rtPlusWeather.PropagationModels(1).MaxNumReflections = 2;
rtPlusWeather.PropagationModels(1).AngularSeparation = "low";

ss = sigstrength(rxs,tx,rtPlusWeather);
disp("Received power two-reflection paths: " + ss + " dBm")

clearMap(viewer)
raytrace(tx,rxs,rtPlusWeather)

%Plot Propagation Paths Including Two Reflections and One Diffraction

rtPlusWeather.PropagationModels(1).MaxNumDiffractions = 1;

ss = sigstrength(rxs,tx,rtPlusWeather);
disp("Received power  two-reflection + one-diffraction: " + ss + " dBm")

raytrace(tx,rxs,rtPlusWeather)

%View Coverage Map with Single-Reflection Paths

rtPlusWeather.PropagationModels(1).MaxNumReflections = 1;
rtPlusWeather.PropagationModels(1).MaxNumDiffractions = 0;
clearMap(viewer)
show(tx)

coverage(tx,rtPlusWeather, ...
    SignalStrengths=-120:-5, ...
    MaxRange=250, ...
    Resolution=2, ...
    Transparency=0.6)

%View Coverage Map with Two Reflections and One Diffraction

rtPlusWeather.PropagationModels(1).MaxNumReflections = 2;
rtPlusWeather.PropagationModels(1).MaxNumDiffractions = 1;
rtPlusWeather.PropagationModels(1).AngularSeparation = "high";
clearMap(viewer)

show(tx)

% load("coverageResultsTwoRefOneDiff.mat");
% contour(coverageResultsTwoRefOneDiff, ...
%     Type="power", ...
%     Transparency=0.6)

% coverage(tx,rtPlusWeather, ...
%     SignalStrengths=-120:-5, ...
%     MaxRange=250, ...
%     Resolution=2, ...
%     Transparency=0.6)