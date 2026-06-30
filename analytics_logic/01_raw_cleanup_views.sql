CREATE OR REPLACE TABLE `berlin-taxi-optimization.berlin_fleet_raw.taxi_trips_weather_log` AS
SELECT
    t.trip_id,
    t.timestamp,
    t.pickup_district,
    t.driver_id,
    t.driver_status,
    t.trip_duration_mins,
    t.fare_amount_euros,
    w.temperature_celsius,
    w.rain_mm

FROM `berlin-taxi-optimization.berlin_fleet_raw.taxi_trips` t

JOIN `berlin-taxi-optimization.berlin_fleet_raw.weather_hourly` w
    ON TIMESTAMP_TRUNC(t.timestamp, HOUR) = w.timestamp_hour;
