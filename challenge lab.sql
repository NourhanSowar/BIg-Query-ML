--Create a forecasting BigQuery machine learning model  

-- Query 1 ---------------------------------
CREATE OR REPLACE MODEL bike.first_model

OPTIONS

  (model_type='linear_reg', labels=['duration_minutes']) AS

SELECT

    start_station_name,

    EXTRACT(HOUR FROM start_time) AS start_hour,

    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,

    duration_minutes,

    address AS location

FROM

    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips

JOIN

    `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations

ON

    trips.start_station_name = stations.name

WHERE

    EXTRACT(YEAR FROM start_time) = 2018

    AND duration_minutes > 0


----------Query 2----------------------------------
CREATE OR REPLACE MODEL bike.second_model

OPTIONS

  (model_type='linear_reg', labels=['duration_minutes']) AS

SELECT

    start_station_name,

    EXTRACT(HOUR FROM start_time) AS start_hour,

    subscriber_type,

    duration_minutes

FROM `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips

WHERE EXTRACT(YEAR FROM start_time) = 2018

--------------------------------------------------
--Evaluate the two machine learning models------


----------Query 1

SELECT

  SQRT(mean_squared_error) AS rmse,

  mean_absolute_error

FROM

  ML.EVALUATE(MODEL bike.first_model, (

  SELECT

    start_station_name,

    EXTRACT(HOUR FROM start_time) AS start_hour,

    EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week,

    duration_minutes,

    address as location

  FROM

    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips

  JOIN

   `bigquery-public-data.austin_bikeshare.bikeshare_stations` AS stations

  ON

    trips.start_station_name = stations.name

  WHERE EXTRACT(YEAR FROM start_time) = 2019)

)


--------Query 2

SELECT

  SQRT(mean_squared_error) AS rmse,

  mean_absolute_error

FROM

  ML.EVALUATE(MODEL bike.second_model, (

  SELECT

    start_station_name,

    EXTRACT(HOUR FROM start_time) AS start_hour,

    subscriber_type,

    duration_minutes

  FROM

    `bigquery-public-data.austin_bikeshare.bikeshare_trips` AS trips

  WHERE

    EXTRACT(YEAR FROM start_time) = 2019)

)

---------------------------------------
---predict average trip durations------------

SELECT AVG(predicted_duration_minutes) AS average_predicted_trip_length

FROM ML.predict(MODEL bike.second_model, (

SELECT

    start_station_name,

    EXTRACT(HOUR FROM start_time) AS start_hour,

    subscriber_type,

    duration_minutes

FROM

  `bigquery-public-data.austin_bikeshare.bikeshare_trips`

WHERE 

  EXTRACT(YEAR FROM start_time) = 2019

  AND subscriber_type = 'Single Trip'














