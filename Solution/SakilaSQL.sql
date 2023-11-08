use sakila;
select title,sum(rental_rate*rental_duration) as rent from film
group by title
having rent in(select max(rental_rate*rental_duration) as rent from film);

create table country_region as (
select country,
case 
when country in ("Algeria" , "Angola" , "Cameroon" , "Chad" , "Congo, The Democratic Republic of the" , "Gambia" , "Kenya" , "Madagascar" , "Malawi" , "M,occo" , "Mozambique" , "Nigeria" , "Senegal" , "South Africa" , "Sudan" , "Tunisia" , "Zambia")
then "Africa"
when country in ("Afghanistan" , "Armenia" , "Azerbaijan" , "Bahrain" , "Bangladesh" , "Brunei" , "Cambodia" , "China" , "Hong Kong" , "India" , "Indonesia" , "Iran" , "Iraq" , "Israel" , "Japan" , "Kazakstan" , "Kuwait" , "Malaysia" , "Myanmar" , "Nauru" , "Nepal" , "Oman" , "Pakistan" , "Saudi Arabia" , "Sri Lanka" , "Taiwan" , "Thailand" , "Turkey" , "Turkmenistan" , "United Arab Emirates" , "Yemen")
then "Asia"
when country in ("Austria" , "Belarus" , "Bulgaria" , "Czech Republic" , "Estonia" , "Finland" , "France" , "Germany" , "Greece" , "Greenland" , "Holy See (Vatican City State)" , "Hungary" , "Italy" , "Latvia" , "Liechtenstein" , "Lithuania" , "Netherlands" , "Poland" , "Romania" , "Réunion" , "Russian Federation" , "Slovakia" , "Spain" , "Sweden" , "Switzerland" , "Ukraine" , "United Kingdom" , "Yugoslavia")
then "Europe"
when country in ("American Samoa" , "Canada" , "United States" , "Virgin Islands, U.S.")
then "North america"
when country in ("Argentina" , "Bolivia" , "Brazil" , "Chile" , "Colombia" , "Ecuad," , "Peru" , "Paraguay" , "Venezuela")
then "South america"
when country in ("Australia" ,"Fiji","French Polynesia" , "New Zealand" , "Tonga" , "Tuvalu")
then "Oceania"
else "others"
end as Regions 
from country); 

select * from country_region;

/*Store wise inventory*/
select store_id,count(film_id)
from inventory
group by store_id;


/*EDA Soln 1*/

select customer_id,count(rental_id) from rental 
where datediff(last_update,rental_date)<=30
group by customer_id;

with cte as
(
select customer_id,count(rental_id) from rental 
where rental_date <= date_sub(last_update, interval 30 day)
group by customer_id
)
select count(customer_id) from cte 
where customer_id not in 
	(	select distinct customer_id from rental 
		where datediff(last_update,rental_date)<=30
	);
    
select customer.customer_id,
count(rental.rental_id) as rental_count
from customer left join rental 
on customer.customer_id=rental.customer_id
group by customer.customer_id
having count(rental.rental_id)<=1 
order by customer.customer_id;


/*EDA Soln 2*/

select film.title,film.rental_rate,count(rental.rental_id) as rental_count
from film
inner join inventory on inventory.film_id=film.film_id
inner join rental on rental.inventory_id=inventory.inventory_id
group by film.title,film.rental_rate
order by rental_count desc 
limit 10;


/*EDA Soln 3*/

select film.rental_rate,sum(payment.amount) from film
inner join inventory on film.film_id=inventory.film_id
inner join rental on inventory.inventory_id=rental.inventory_id
inner join payment on rental.rental_id=payment.rental_id
group by 1 
order by 1;


/*EDA Soln 4*/

select year(payment_date),month(payment_date),sum(amount) 
from payment
group by 1,2;

select  country_region.regions,
case when  month(rental.rental_date) between "5" and "6" then "Summer/Winter" 
	 else "Autumn/Spring"
end as Season, 
count(rental.rental_id) as rental_count
from rental
inner join customer on customer.customer_id=rental.customer_id
inner join address on address.address_id=customer.address_id
inner join city on city.city_id=address.city_id
inner join country on country.country_id=city.country_id
inner join country_region on country_region.country=country.country
group by 1,2;


/*EDA Soln 6*/

select year(payment_date),month(payment_date),sum(amount) 
from payment
group by 1,2;


/*EDA Soln 7*/

with region as 
(
select country,
case 
when country in ("Algeria" , "Angola" , "Cameroon" , "Chad" , "Congo, The Democratic Republic of the" , "Gambia" , "Kenya" , "Madagascar" , "Malawi" , "M,occo" , "Mozambique" , "Nigeria" , "Senegal" , "South Africa" , "Sudan" , "Tunisia" , "Zambia")
then "Africa"
when country in ("Afghanistan" , "Armenia" , "Azerbaijan" , "Bahrain" , "Bangladesh" , "Brunei" , "Cambodia" , "China" , "Hong Kong" , "India" , "Indonesia" , "Iran" , "Iraq" , "Israel" , "Japan" , "Kazakstan" , "Kuwait" , "Malaysia" , "Myanmar" , "Nauru" , "Nepal" , "Oman" , "Pakistan" , "Saudi Arabia" , "Sri Lanka" , "Taiwan" , "Thailand" , "Turkey" , "Turkmenistan" , "United Arab Emirates" , "Yemen")
then "Asia"
when country in ("Austria" , "Belarus" , "Bulgaria" , "Czech Republic" , "Estonia" , "Finland" , "France" , "Germany" , "Greece" , "Greenland" , "Holy See (Vatican City State)" , "Hungary" , "Italy" , "Latvia" , "Liechtenstein" , "Lithuania" , "Netherlands" , "Poland" , "Romania" , "Réunion" , "Russian Federation" , "Slovakia" , "Spain" , "Sweden" , "Switzerland" , "Ukraine" , "United Kingdom" , "Yugoslavia")
then "Europe"
when country in ("American Samoa" , "Canada" , "United States" , "Virgin Islands, U.S.")
then "North america"
when country in ("Argentina" , "Bolivia" , "Brazil" , "Chile" , "Colombia" , "Ecuad," , "Peru" , "Paraguay" , "Venezuela")
then "South america"
when country in ("Australia" ,"Fiji","French Polynesia" , "New Zealand" , "Tonga" , "Tuvalu")
then "Oceania"
else "others"
end as Regions
from country
)
select region.regions,category.name,count(rental.rental_id)
from
category inner join film_category on category.category_id=film_category.category_id
inner join film on film.film_id=film_category.film_id
inner join inventory on film.film_id=inventory.film_id
inner join rental on rental.inventory_id=inventory.inventory_id
inner join customer on customer.customer_id=rental.customer_id
inner join address on address.address_id=customer.address_id
inner join city on city.city_id=address.city_id 
inner join country on country.country_id=city.country_id
inner join region on region.country=country.country
group by 1,2
order by 1;

select c.name,count(distinct f.film_id) as film_count from
category c inner join film_category fc on c.category_id=fc.category_id
inner join film f on f.film_id=fc.film_id
left join inventory i on f.film_id=i.film_id
left join rental r on r.inventory_id=i.inventory_id
group by 1;


/*EDA Soln 8*/

select store_id,rating,count(inventory_id) from inventory 
inner join film on inventory.film_id=film.film_id
group by store_id,rating;


/*EDA Soln 9*/

select store_id,city,country 
from store
left join address
on store.address_id = address.address_id
left join city 
on address.city_id = city.city_id
left join country
on city.country_id = country.country_id;

select country,count(rental_id) from rental 
left join customer on rental.customer_id=customer.customer_id
left join address on customer.address_id=address.address_id
left join city on address.city_id = city.city_id
left join country on city.country_id = country.country_id
group by country
order by 2 desc;



/*EDA Soln 10*/

select  
case when film.rating ="G" then "All-Age"
	 when film.rating = "PG" then "Above 7yrs"
	 when film.rating= "PG-13" then "Above 13yrs"
	 when film.rating = "R" or film.rating = "NC-17" then "Above 18yrs"
end as age_category,category.name,
count(rental.rental_id) as rental_count
from film 
inner join inventory on inventory.film_id=film.film_id
inner join rental on rental.inventory_id=inventory.inventory_id
inner join customer on rental.customer_id=customer.customer_id
inner join film_category on inventory.film_id=film_category.film_id
inner join category on category.category_id=film_category.category_id
group by age_category,category.name;


/*EDA Soln 11*/

select customer.customer_id from customer
left join payment on payment.customer_id=customer.customer_id
group by customer.customer_id
order by sum(payment.amount) desc
limit 20;

select customer.customer_id,film.rating,category.name,count(rental.rental_id)
from customer left join rental on customer.customer_id=rental.customer_id
inner join inventory on rental.inventory_id=inventory.inventory_id
inner join film_category on inventory.film_id=film_category.film_id
inner join film on film.film_id=film_category.film_id
inner join category on category.category_id=film_category.category_id
where customer.customer_id in (50, 137, 144, 148, 176, 178, 181, 209, 236, 259,
							   295, 373, 403, 410, 459, 468, 469, 470, 522, 526)
group by 1,2,3;


/*EDA Soln 12*/

with cte as 
(
select rental.rental_id, rental.return_date, rental.rental_date,film.rental_duration,
case when film.rental_duration>datediff(rental.return_date,rental.rental_date) then "Early Returns"
	 when film.rental_duration = datediff(rental.return_date,rental.rental_date) then "Returned on Time"
	 else "Late Returns"
end as return_status
from rental
inner join inventory on rental.inventory_id=inventory.inventory_id
inner join film on inventory.film_id = film.film_id
order by 1
)
select return_status,count(*) as "Film Count"
from cte
group by return_status;


/*EDA Soln 13*/

select 
dayname(rental.rental_date) as day_of_week,
hour(rental.rental_date) as hour_of_day,
sum(case when inventory.store_id = 1 then 1 else 0 end) as store1_rental
from rental
inner join inventory
on rental.inventory_id = inventory.inventory_id
group by day_of_week,hour_of_day
order by store1_rental desc; 

select 
dayname(rental.rental_date) as day_of_week,
hour(rental.rental_date) as hour_of_day,
sum(case when inventory.store_id = 2 then 1 else 0 end) as store2_rental
from rental
inner join inventory
on rental.inventory_id = inventory.inventory_id
group by day_of_week,hour_of_day
order by store2_rental desc; 


/*EDA Soln 14*/

select  country_region.regions,film.rating,
count(distinct customer.customer_id) as customer_preference
from film
inner join inventory on film.film_id=inventory.film_id
inner join rental on rental.inventory_id=inventory.inventory_id
inner join customer on customer.customer_id=rental.customer_id
inner join address on address.address_id=customer.address_id
inner join city on city.city_id=address.city_id
inner join country on country.country_id=city.country_id
inner join country_region on country_region.country=country.country
group by 1,2;


/*EDA Soln 15*/

select film.length,count(rental.rental_id) from film
left join inventory on film.film_id=inventory.film_id
inner join rental on inventory.inventory_id=rental.inventory_id
group by 1
order by 1;
