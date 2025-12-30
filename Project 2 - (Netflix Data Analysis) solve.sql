USE netflix;
SELECT * FROM adultacc;
SELECT * FROM childacc;
SELECT * FROM content;
SELECT *  FROM customers;
SELECT * FROM customerslanguagepreferred;
SELECT * FROM devices;
SELECT * FROM paymenthistory;
SELECT * FROM paymentmethod;
SELECT * FROM plans;
SELECT * FROM profiles;
SELECT * FROM subscribes;
SELECT * FROM uses;
SELECT * FROM viewinghistory;

#1. Using the Viewing History table, identify the top 3 most-watched movies based on viewing hours. 
SELECT * FROM viewinghistory;

SELECT
 ContentID,
 SUM(Runtime) AS total_viewing_hours
 FROM viewingHistory
 GROUP BY contentId
 ORDER BY total_viewing_hours DESC
 LIMIT 3;
  
# 2. Partition the viewing hours by category and genre to find the top genre in each category. Use the rank function to rank genres within each category.
SELECT * FROM content;
SELECT * FROM viewinghistory;

WITH genre_hours AS(
SELECT
  c.Category,
  c.Genre,
  SUM(v.Runtime) AS TotalViewingHours
  FROM viewinghistory v
  JOIN content c
   ON v.ContentID = c.ContentID
   GROUP BY
   c.category,
   c.Genre
   ),
   ranked_genres AS (
   SELECT
    Category,
    Genre,
    TotalViewingHours,
    RANK() OVER (
    PARTITION BY Category
    ORDER BY TotalViewingHours DESC
    ) AS rnk
    FROM genre_hours
    )
    SELECT *
    FROM ranked_genres
    WHERE rnk = 1;

# 3. Determine the number of subscriptions for each plan. Display Plan ID, Plan Name and Subscriber count in descending order of Subscriber count. 
SELECT * FROM plans;
SELECT * FROM subscribes;

SELECT
 p.PlanID,
 p.PlanName,
 COUNT(S.PlanID) AS subscribercount
FROM plans p
LEFT JOIN subscribes s
  ON p.PlanID = s.PlanID
GROUP BY
 p.PlanID,
 p.PlanName
 ORDER BY
  subscribercount DESC;
  
# 4. Which device type is most commonly used to access Netflix content? Provide the Device Type and count of accesses. 
SELECT * FROM devices;
SELECT * FROM uses;

SELECT
 d.DeviceType,
 COUNT(*) AS AccessCount
 FROM uses u
 JOIN devices d
  ON u.DeviceID = d.DeviceID
GROUP BY d.DeviceType
ORDER BY Accesscount DESC
LIMIT 1;

# 5. Compare the viewing trends of movies versus TV shows. What is the average viewing time for movies and TV shows separately? 
SELECT * FROM content;
SELECT * FROM viewinghistory;

SELECT
 c.category,
 AVG(V.Runtime) AS AverageViewingTime
FROM viewingHistory v
JOIN content c
 ON v.contentID = c.ContentID
GROUP BY
 c.Category;
 
 # 6. Identify the most preferred language by customers. Provide the number of customers, and language. 
SELECT * FROM customerslanguagepreferred;

SELECT
 Language,
 COUNT(*) AS customercount
FROM customerslanguagepreferred
GROUP BY Language
ORDER BY CustomerCount DESC
LIMIT 1;

# 7. How many customers have adult accounts versus child accounts? Provide the count for each type. 
SELECT * FROM adultacc;
SELECT * FROM childacc;

SELECT 'Adult' AS AccountType, COUNT(*) AS Total
FROM adultacc
UNION ALL
SELECT 'child' AS AccountType, COUNT(*) AS Total
FROM childacc;

# 8. Determine the average number of profiles created per customer account. 
SELECT *  FROM customers;
SELECT * FROM adultacc;
SELECT * FROM childacc;

SELECT 
 (
  (SELECT COUNT(*) FROM adultacc)+
  (SELECT COUNT(*) FROM childacc)
  )*10
  /
  (SELECT COUNT(*) FROM customers)
  AS AverageProfilesPerCustomer;

# 9. Identify the content that has the lowest average viewing time per user. Provide the titles and their average viewing time. 
SELECT * FROM content;
SELECT * FROM viewinghistory;

SELECT 
 ContentID,
 AVG(Runtime) AS AvgViewingTime
FROM viewinghistory v
GROUP BY ContentID
ORDER BY AvgViewingTime ASC
LIMIT 1;

# 10. Determine the count for each content type. 
SELECT * FROM content;

SELECT Category, COUNT(*) AS TotalContent
FROM content
GROUP BY Category;

# 11. Compare the number of customers that have unlimited access and who do not. 
SELECT * FROM subscribes;
SELECT * FROM plans;

SELECT
 p.ContentAccess,
 COUNT(*) AS TotalCustomers
FROM subscribes s
JOIN plans p
 ON s.PlanID = p.PlanID
GROUP BY p.ContentAccess;

# 12. Find Average monthly price for plans with Content Access as "unlimited". 
SELECT * FROM plans;

SELECT
 AVG(MonthlyPrice) AS AverageMonthlyPrice
FROM plans
WHERE ContentAccess = 'unlimited';

# 13. List all the customers who have taken the plan for till 2028 and later.Display CustomerID, Customer name and Expiration Date of the plan, ordered by Expiration Date in descending order first, and then by Customer Name. 
 SELECT * FROM customers;
 SELECT * FROM paymentmethod;
 
 SELECT
  c.CUSTID,
  CONCAT(c.FNAME,'',c.LNAME) AS CustomerName,
  pm.ExpirationDate
FROM paymentmethod pm
JOIN customers c
 ON pm.CUSTID = c.CUSTID
WHERE pm.ExpirationDate >= '2028-01-01'
ORDER BY
 pm.ExpirationDate DESC,
 CustomerName ASC;
 
# 14. Display Average Revenue generated from each city. Rank city based on average revenue. 
SELECT * FROM plans;
SELECT * FROM subscribes;
SELECT * FROM customers;

SELECT 
 c.Country,
  AVG(p.MonthlyPrice) AS AverageRevenue
FROM subscribes s
JOIN customers c ON s.CUSTID = c.CUSTID
JOIN plans p ON s.PlanID = p.PlanID
GROUP BY c.Country
ORDER BY AverageRevenue DESC; 

# 15. Display most frequently viewed genre among adults for each category. 
SELECT * FROM adultacc;
SELECT * FROM content;
SELECT * FROM viewinghistory;

SELECT Category, Genre, ViewCount
FROM (
    SELECT 
        c.Category,
        c.Genre,
        COUNT(*) AS ViewCount,
        ROW_NUMBER() OVER (
            PARTITION BY c.Category 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM adultacc a
    JOIN viewinghistory v ON a.ProfileID = v.ProfileID
    JOIN content c ON v.ContentID = c.ContentID
    GROUP BY c.Category, c.Genre
) AS t
WHERE rn = 1;
