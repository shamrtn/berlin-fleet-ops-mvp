WITH ranked_trips AS (
SELECT 
  t.trip_id,
  t.driver_id,
  t.driver_status,
  t.timestamp AS trip_timestamp,
  c.district,
  c.club_name,
  c.demand_weight,
  ROW_NUMBER() OVER(
    partition by t.trip_id
    order by c.demand_weight desc)
    as row_num
FROM `berlin-taxi-optimization.berlin_fleet_raw.taxi_trips` t
JOIN `berlin-taxi-optimization.berlin_fleet_raw.berlin_clubs_active_windows` c
  ON t.pickup_district = c.district
  -- Match the trip's day of the week (e.g., 'Friday') to the surge window day
  AND FORMAT_TIMESTAMP('%A', t.timestamp, 'Europe/Berlin') = c.day_of_week
  -- Match the trip's hour (0-23) to the surge window hour
  AND EXTRACT(HOUR FROM t.timestamp AT TIME ZONE 'Europe/Berlin') = c.surge_hour
WHERE 
  -- Condition 1: Capture ongoing operations for the entire peak hour block
  (c.is_active_operating_hour = 1)
  OR
  -- Condition 2: Filter closing rush hours to just the first 30 minutes
  (c.is_closing_rush = 1 AND EXTRACT(MINUTE FROM t.timestamp AT TIME ZONE 'Europe/Berlin') <= 30)
  -- This outer query filters out all duplicates completely
)
SELECT 
  trip_id,
  driver_id,
  driver_status,
  trip_timestamp,
  club_name,
  district,
  demand_weight
FROM ranked_trips
WHERE row_num = 1; -- Keeps exactly one row per trip_id
