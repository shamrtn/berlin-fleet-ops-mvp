# 🚕 Berlin Nightlife Fleet Optimization Pipeline

An end-to-end data pipeline built to optimize ride-hailing fleet efficiency across Berlin during volatile weekend peak nightlife hours. 

This project simulates vehicle telemetry, integrates real-world venue data, transforms the datasets natively inside Google BigQuery to handle temporal overlaps, and exposes operational bottlenecks via an interactive Data Studio dashboard.

---

## 📊 Looker Data Studio Dashboard
The interactive dashboard analyzes fleet utilization and exposes the structural flaws of static vehicle allocation models under real-world pressure.

* 🔗 **[Live Interactive Dashboard Link](#)** *(https://datastudio.google.com/reporting/f6e8cdb2-a4fa-4cf9-97cc-b326e5166909)*
* 📄 **[Static PDF Version](Fleet_Optimization_Dashboard.pdf)**

---

## 🏗️ Repository Architecture

The project is structured logically to reflect a production-grade data engineering lifecycle:

```text
├── data_ingestion/
│   ├── 01.Simulate_trips_Berlin.ipynb     # Generates 5,000 raw trip logs & vehicle telemetry for 3 weeks
│   ├── 02.Weather_fetch_api.ipynb     # Extracts historical weather data for 3 weeks + 5 days lag
│   └── 03.Berlin_clubs.ipynb         # Processes dataframes for Berlin clubs & active hours
│
├── data_warehouse/
│   ├── 01.berlin_taxi_trips_raw.csv    # Initial vehicle log output (5,000 rows)
│   ├── 02.berlin_weather_raw.csv       # Historical summer weather dataset
│   ├── 03a.berlin_clubs.csv          # Static venue metadata (capacities, demand tiers)
│   └── 03b.berlin_clubs_active_windows.csv # Temporal operational windows per club
│
├── analytics_logic/
│   ├── 01_raw_cleanup_views.sql   # Joined tables for weather and taxi trips
│   ├── 02_trip_club_window_join.sql # Joined view with active clubs hours and taxi trips
│   └── 03_final_joined_table.sql  # Final joined tables of the data warehouse for Data Studio
│
└── README.md
```

# 🛠️ Data Pipeline Details
## 1. Data Ingestion & Environmental Factors
Telemetry Simulation: A Python script generates 5,000 raw weekend trips across Berlin, simulating driver coordinates, timestamps, and trip IDs.

Weather Integration: Historical summer weather data was fetched via API. Analysis revealed an average consistent temperature of 17°C with negligible impact on trip patterns across the 3-week dataset. The pipeline infrastructure is retained to support future seasonal scaling, while the core analytical dataset was filtered to 1,000 unique rows representing active weekend nightlife hours.

Granular Venue Logic: Features custom operating matrices mapping the unique exit rushes of standard clubs versus multi-day marathon venues (e.g., Sisyphos which opens from Friday night through Monday morning).

## 2. Analytics & BigQuery Transformations (analytics_logic/)
To prevent BI dashboard lag and handle complex string/time operations, all data transformation was executed natively in Google BigQuery:

*01_raw_cleanup_views.sql*: Standardizes datatypes, normalizes borough names, and extracts clean timestamp filters.

*02_trip_club_window_join.sql*: Joins simulated telemetry with active club windows.

The Deduplication Challenge: Clubs in the same district operating in overlapping time windows competed for identical taxi trip_ids, causing row duplication. This query cleanly strips duplicate rows to maintain an unskewed dataset. If two Level 3 demand venues (e.g., Sisyphos and Berghain because of being located in the same district) compete for the same trip row, the query applies an alphabetical deduplication filter, defaulting cleanly to one venue per record.

*03_final_joined_table.sql*: Aggregates total demand and flattens data structures into a clean analytical presentation layer optimized for Data Studio.

# 📈 The Business Case & Data Insights
The Static Baseline Breakdown
Evaluating a traditional daytime baseline split (40% Mitte / 30% Friedrichshain-Kreuzberg / 30% Prenzlauer Berg) against nightlife data revealed severe operational inefficiencies:

Total Volume Illusion: Aggregate dashboard numbers show an "accumulated demand" (the aggregate sum of every row of passenger demand recorded) of 1,500 units in Mitte and 1,300 in Friedrichshain/Kreuzberg.

The 5:00 AM Crisis: Looking past total nightly volumes to real-time compression highlights a massive bottleneck. At 5:00 AM, demand spikes suddenly to an accumulated peak score of 200 units based on club exit flows, forcing a Fleet Utilization score of just 61.4%. Nearly 40% of fleet capacity is entirely wasted on unbilled kilometers.

Operational Blindness: At peak hours, Mitte holds a surplus of 118 idle trips while its local demand fades. Concurrently, Friedrichshain/Kreuzberg drivers sit idle during their local peak window. Drivers are functionally blind—stuck in dead zones or waiting blocks away from dense club crowds without precise coordinates.

# 🚀 The Recommendation: Dynamic Reallocation Pipeline
This project recommends a shift from a static distribution model to a Dynamic Reallocation Pipeline running automated logic 30 minutes prior to peak nightlife rushes (4:30 AM):

District Shifting: Automatically flag idle vehicles in cooling sectors (Mitte) and proactively route 78 vehicles across district lines into high-demand sectors (Friedrichshain/Kreuzberg).

Micro-Routing: Push real-time, granular crowd-density coordinates directly to the idle drivers already within Friedrichshain/Kreuzberg, micro-routing them away from empty streets straight to active venue doors.

