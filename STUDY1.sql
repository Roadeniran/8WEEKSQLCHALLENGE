
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    S.CUSTOMER_ID, S.PRODUCT_ID, SUM(M.PRICE) AS TOTAL_SPENT
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY customer_id
;


-- 2. How many days has each customer visited the restaurant?
SELECT 
    CUSTOMER_ID, COUNT(DISTINCT order_date) AS VISIT_FREQ
FROM
    sales
GROUP BY customer_id
;
-- THE DISTINCT TO ELIMINATE CUSTOMERS THAT VISITED MORE THAN ONCE IN THE SAME DAY


-- 3. What was the first item from the menu purchased by each customer?

select distinct * from 
	(SELECT 
    S.CUSTOMER_ID,  M.PRODUCT_NAME, rank() over (partition by s.customer_id order by order_date asc ) as order_rnk
	FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID) A
where order_rnk = 1
;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    M.PRODUCT_NAME, COUNT(S.PRODUCT_ID) AS Top_order
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY product_name
ORDER BY Top_ORDER DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?
WITH Customer_Top_Order as (SELECT 
    s.customer_id, m.PRODUCT_NAME, COUNT(S.PRODUCT_ID), rank() over( partition by customer_id order by count(s.product_id) desc) as rnk
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
    group by product_name, customer_id)
    select * from
    Customer_Top_Order
    where rnk = 1;
    
-- 6. Which item was purchased first by the customer after they became a member?
 WITH FIRST_MEAL AS (SELECT 
    s.customer_id, m.PRODUCT_NAME, MB.JOIN_DATE, ORDER_DATE, RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE ASC) AS RNK
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
		JOIN
	MEMBERS MB ON S.CUSTOMER_ID = MB.CUSTOMER_ID
    WHERE ORDER_DATE >= JOIN_DATE 
    group by product_name, customer_id)
    SELECT * FROM FIRST_MEAL
    WHERE RNK = 1
   ;
   
   
-- 7. Which item was purchased just before the customer became a member?
WITH LAST_MEAL AS (SELECT 
    s.customer_id, m.PRODUCT_NAME, MB.JOIN_DATE, ORDER_DATE, RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS RNK
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
		JOIN
	MEMBERS MB ON S.CUSTOMER_ID = MB.CUSTOMER_ID
    WHERE ORDER_DATE < JOIN_DATE 
    group by product_name, customer_id)
    SELECT * FROM LAST_MEAL
    WHERE RNK = 1
   ;
   
   
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
    s.customer_id, COUNT(DISTINCT PRODUCT_NAME) AS ORDERS, SUM(PRICE) AS TOTAL_SPENT
FROM
    sales S
        JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID
		JOIN
	MEMBERS MB ON S.CUSTOMER_ID = MB.CUSTOMER_ID
    WHERE ORDER_DATE < JOIN_DATE 
    group by customer_id
    ORDER BY customer_id;
    
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 SELECT 
customer_id, 
   SUM(CASE WHEN M.PRODUCT_ID = 1 THEN 20*PRICE
   ELSE 10*PRICE END) AS POINTS
FROM
    sales S
       INNER JOIN
    MENU M ON S.PRODUCT_ID = M.PRODUCT_ID 
    GROUP BY S.customer_id;
    
    SELECT CUSTOMER_ID, SUM(CTE.POINTS)
    FROM CTE
    GROUP BY CUSTOMER_ID;
    
    
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 SELECT 
S.customer_id, 
	SUM(CASE WHEN S.ORDER_DATE >= MB.JOIN_DATE AND S.ORDER_DATE <= MB.JOIN_DATE + 6 THEN 20*PRICE
		ELSE ( 
    CASE WHEN M.PRODUCT_ID = 1 THEN 20*PRICE
		ELSE 10*PRICE END)  END ) AS POINTS
FROM
		sales S
	JOIN
		MENU M ON S.PRODUCT_ID = M.PRODUCT_ID 
	JOIN 
		MEMBERS MB ON MB.CUSTOMER_ID = S.CUSTOMER_ID
    WHERE ORDER_DATE BETWEEN '2021-01-01' AND '2021-01-31'
	GROUP BY MB.customer_id
    ORDER BY customer_id;



    
    
    
    
   
    
    

