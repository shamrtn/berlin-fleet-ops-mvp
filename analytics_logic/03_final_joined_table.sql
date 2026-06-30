CREATE OR REPLACE TABLE `berlin-taxi-optimization.berlin_fleet_raw.final_club_weather_analytics` AS
SELECT
    -- Pull the operational and weather data from my base log
    w.trip_id,
    w.timestamp,
    w.pickup_district,
    w.driver_id,
    w.driver_status,
    w.trip_duration_mins,
    w.fare_amount_euros,
    w.temperature_celsius,
    w.rain_mm,
    -- Pull the specific club context from my view
    c.club_name,
    c.demand_weight

FROM `berlin-taxi-optimization.berlin_fleet_raw.taxi_trips_weather_log` w
-- INNER JOIN ensures we ONLY keep rows that match your active club windows
INNER JOIN `berlin-taxi-optimization.berlin_fleet_raw.clubs_active_trips` c
    ON w.trip_id = c.trip_id;
