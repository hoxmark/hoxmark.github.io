---
layout: page
title: Solsti
description: Sun-optimized walking route planner for iOS
img: assets/img/solsti-icon.png
importance: 1
category: work
giscus_comments: false
---

## Solsti - Finn den solrikeste veien

Solsti is a walking route planner app that optimizes routes based on sun conditions. Whether you want to enjoy the sun or stay in the shade, Solsti finds the best route for you.

<div class="row mt-3">
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Simulator Screenshot - iPhone 17 Pro Max - 2026-03-11 at 10.46.10.png" class="img-fluid rounded z-depth-1" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Simulator Screenshot - iPhone 17 Pro Max - 2026-03-11 at 10.48.01.png" class="img-fluid rounded z-depth-1" %}
    </div>
    <div class="col-sm mt-3 mt-md-0">
        {% include figure.liquid loading="eager" path="assets/img/Simulator Screenshot - iPhone 17 Pro Max - 2026-03-11 at 10.49.25.png" class="img-fluid rounded z-depth-1" %}
    </div>
</div>

### Key Features
- **Sun-Optimized Routes**: Plans walking routes that maximize sun exposure or shade based on your preference
- **Time-of-Day Planning**: Select any time to see sun conditions throughout the day
- **Multiple Route Types**: 
  - Round trips starting from your location (15, 30, 45, or 60 minutes)
  - Routes to a specific destination
  - Pin-to-pin routing with custom start and end points
- **Visual Color Coding**: Routes are color-coded to show sun and shade for each street segment
  - 🟡 Gold: Full sun exposure
  - 🔵 Blue: Full shade
  - 🟦 Blue/Gold gradient: Partial sun
- **Real-Time Shadow Calculation**: Uses actual building and tree heights to calculate shadows based on sun position

### How It Works

1. **Road Network Data**: Fetches road data from OpenStreetMap for your area
2. **Shadow Calculations**: Uses LiDAR elevation data (DSM−DTM) from Kartverket to calculate shadows from buildings and trees based on sun position
3. **Route Optimization**: Uses A* pathfinding algorithm to find the optimal route balancing distance and sun exposure. For round trips, uses Yen's K-shortest paths to generate candidate routes
4. **Visualization**: Displays the route on a map with color coding showing sun and shade for each street segment

### Technical Deep-Dive

#### Sun Position Algorithm (NOAA)
Calculates the sun's elevation and azimuth using NOAA's Simplified Solar Position Algorithm. Converts Julian date and UTC time to Julian century (T), then computes the sun's mean ecliptic longitude, mean anomaly, and equation of center correction. The result is the sun's true ecliptic longitude, projected to equatorial coordinates (right ascension and declination) via the ecliptic's obliquity. Finally transforms to horizontal coordinates (azimuth + elevation) based on observer's latitude/longitude and hour angle. Verified against pysolar (NREL SPA) with average errors < 0.05° for elevation and < 0.01° for azimuth.

#### Graph Building from OpenStreetMap
Road network is fetched from OpenStreetMap via Overpass API as a list of "ways" and associated "nodes". GraphBuilder converts these into a weighted, undirected graph: each pair of consecutive nodes along a way becomes one edge (GraphEdge). Edge weight is the haversine distance between the node pair in meters. One-way streets are respected with directed edges.

#### Shadow Calculation via Ray-Marching (DSM−DTM)
For each road segment, the ExposureEngine samples points at 10-meter intervals along the polyline. From each point, a "shadow ray" is sent horizontally toward the sun (azimuth) through a raster of height differences (DSM minus DTM = net surface height from buildings and trees, from Kartverket's LiDAR data). For each meter along the ray, the algorithm checks if the raster tile's net height is greater than the sun's elevation angle times the horizontal distance. If so, the point is in shade. The exposure score for the edge is the proportion of points in direct sunlight.

#### A* Routing with Sun Weighting (λ-parameter)
For point-to-point routes uses A* with a provably-admissible Haversine heuristic: h(n) = haversine(n, goal) × (1 − λ). This steers the search directly toward the goal, typically exploring 5–10× fewer nodes than pure Dijkstra. For round trips, uses Yen's K-shortest-paths (Dijkstra without heuristic) to generate 5 candidate routes, then ranks them by sun exposure. Edge cost in both cases: cost = lengthM × (1 − λ × sunScore). λ is locked to 1, so Solsti always prioritizes maximum sun (or shade). Path is reconstructed backward via a prev-map from goal to start.

### Data Sources & Attribution

- **Road Data**: © OpenStreetMap contributors (ODbL 1.0)
- **Elevation Data (LiDAR)**: © Kartverket / hoydedata.no (NLOD 2.0)

### Technical Stack
- **Platform**: iOS (SwiftUI)
- **Mapping**: MapKit
- **Data Sources**: OpenStreetMap (Overpass API), Kartverket LiDAR
- **Algorithms**: NOAA Solar Position, A* pathfinding, Yen's K-shortest paths
- **Language**: Swift

### Tips
- Try different times of day – sun conditions change dramatically throughout the day
- Use "Til et sted" for a route to a specific place, or "Pin til pin" to freely choose both start and destination on the map
- The percentage "I sol" shows how much of the route is sunlit
- Move the starting point directly on the map with the pin button after the route is calculated

---

**Platform**: iOS (iPhone)  
**Status**: In Development
