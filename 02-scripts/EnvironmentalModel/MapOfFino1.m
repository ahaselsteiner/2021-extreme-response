fig = figure('position', [100, 100, 400, 400])

worldmap({'Denmark', 'United Kingdom', 'Netherlands, Kingdom of the'})
land = shaperead('landareas.shp', 'UseGeoCoords', true);
geoshow(land, 'FaceColor', [0.15 0.5 0.15])

fino1.Geometry = 'Point';
fino1.Lat = 54.00; %54.0148;
fino1.Lon = 6.575; %6.5876;
fino1.Name = 'D, hindcast'; %Germany
geoshow(fino1, 'Marker', '.', 'MarkerEdgeColor', 'red')
geoshow(fino1, 'Marker', 'o', 'MarkerEdgeColor', 'red', 'markersize', 10)

textm(56, 3, 'North Sea', 'horizontalalignment', 'center')

exportgraphics(gcf, 'gfx/Fino1Location.jpg') 
exportgraphics(gcf, 'gfx/Fino1Location.pdf') 
