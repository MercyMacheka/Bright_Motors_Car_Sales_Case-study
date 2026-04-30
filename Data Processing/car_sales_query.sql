SELECT 
  COALESCE(year, 0) AS year,
  make,
  model,
  body,
  transmission,
  vin,
  
  -- Fix region: uppercase valid state codes, replace VINs/invalid with 'Unknown'
  CASE 
    WHEN state IS NULL THEN 'Unknown'
    WHEN state REGEXP '[0-9]' THEN 'Unknown'  -- Filter out VINs with numbers
    WHEN LENGTH(state) != 2 THEN 'Unknown'     -- Filter out invalid length
    ELSE UPPER(state)
  END AS region,
  
  COALESCE(condition, 0) AS condition,
  COALESCE(odometer, 0) AS mileage,
  
  -- Mileage buckets for analysis
  CASE 
    WHEN COALESCE(odometer, 0) = 0 THEN '0 - No Miles'
    WHEN COALESCE(odometer, 0) < 25000 THEN '1 - Under 25K'
    WHEN COALESCE(odometer, 0) < 50000 THEN '2 - 25K to 50K'
    WHEN COALESCE(odometer, 0) < 75000 THEN '3 - 50K to 75K'
    WHEN COALESCE(odometer, 0) < 100000 THEN '4 - 75K to 100K'
    ELSE '5 - Over 100K'
  END AS mileage_bucket,
  
  color,
  COALESCE(mmr, 0) AS mmr,
  COALESCE(sellingprice, 0) AS selling_price,
  seller,
  
  -- Calculate profit amount (in dollars)
  (COALESCE(sellingprice, 0) - COALESCE(mmr, 0)) AS profit,
  
  -- Calculate profit margin percentage
  ROUND(((COALESCE(sellingprice, 0) - COALESCE(mmr, 0)) / NULLIF(COALESCE(sellingprice, 0), 0)) * 100, 2) AS profit_margin,
  
  -- Performance tier based on selling price
  CASE 
    WHEN COALESCE(sellingprice, 0) >= 50000 THEN 'Premium'
    WHEN COALESCE(sellingprice, 0) >= 30000 THEN 'High'
    WHEN COALESCE(sellingprice, 0) >= 15000 THEN 'Medium'
    ELSE 'Low'
  END AS performance_tier,
  
  -- Units sold (each row represents 1 unit/car sold)
  1 AS units_sold,
  
  -- Date components from saledate
  YEAR(saledate) AS sale_year,
  MONTH(saledate) AS sale_month,
  QUARTER(saledate) AS sale_quarter,
  DAYOFWEEK(saledate) AS day_of_week,
  
  -- Revenue per car sold (selling price of this individual car)
  COALESCE(sellingprice, 0) AS revenue_per_car
  
FROM workspace.default.bright_car_sales
ORDER BY saledate DESC
