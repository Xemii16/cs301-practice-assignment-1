-- show product categories (by state) with avg rating +3 and orders +7 in 2 last years
-- which suppliers is active (consider only customers from FL, TX, and NY),
-- also unite product which was bought by clients from CA (and order desc by total orders)
with categoryOrders as (select products.category, clients.state as state, count(distinct orders.id) as total_orders
                        from store.products products
                                 left join store.orders orders on products.id = orders.product_id
                                 left join store.clients clients on orders.client_id = clients.id
                                 left join store.suppliers suppliers on products.supplier_id = suppliers.id
                        where orders.order_date > now() - interval '2 year'
                          and suppliers.is_active
                        group by products.category, clients.state
                        having count(distinct orders.id) > 7),
     categoryRatings as (select products.category, clients.state as state, avg(reviews.rating) as avg_rating
                         from store.products products
                                  join store.reviews reviews on products.id = reviews.product_id
                                  join store.clients clients on reviews.client_id = clients.id
                         group by products.category, clients.state),
     categoryCA as (select products.category, clients.state as state, count(distinct orders.id) as total_orders
                    from store.products
                             join store.orders orders on products.id = orders.product_id
                             join store.clients clients on orders.client_id = clients.id
                    where clients.state = 'CA'
                    group by products.category, clients.state)
select orders.category, orders.state, total_orders, avg_rating
from categoryOrders orders
         left join categoryRatings ratings on orders.category = ratings.category and orders.state = ratings.state
where total_orders > 7
  and avg_rating > 3
  and orders.state in ('FL', 'TX', 'NY')
union all
(select ca.category, ca.state, total_orders, avg_rating
 from categoryCA ca
          left join categoryRatings ratings on ca.category = ratings.category and ca.state = ratings.state)
order by total_orders desc;