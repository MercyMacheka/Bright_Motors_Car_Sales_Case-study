SELECT 
  year,
  make,
  model,
  body,
  transmission,
  state AS region,
  condition,
  odometer AS mileage,
  color,
  mmr,
  sellingprice AS selling_price,
  
  -- Calculate profit margin percentage
  ROUND(((sellingprice - mmr) / NULLIF(sellingprice, 0)) * 100, 2) AS profit_margin,
  
  -- Performance tier based on selling price
  CASE 
    WHEN sellingprice >= 50000 THEN 'Premium'
    WHEN sellingprice >= 30000 THEN 'High'
    WHEN sellingprice >= 15000 THEN 'Medium'
    ELSE 'Low'
  END AS performance_tier,
  
  -- Number of cars sold (total count as window function)
  COUNT(*) OVER () AS number_of_cars_sold,
  
  -- Date components from saledate
  YEAR(saledate) AS sale_year,
  MONTHNAME(saledate) AS sale_month,
  QUARTER(saledate) AS sale_quarter,
  weEK(saledate) AS day_of_week,
  
  -- Total revenue (sum of all selling prices as window function)
  SUM(sellingprice) OVER () AS total_revenue
  
FROM workspace.default.bright_car_sales
ORDER BY saledate DESC
