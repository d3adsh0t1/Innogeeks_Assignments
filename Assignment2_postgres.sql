create table roles(
            roleId SERIAL PRIMARY KEY,
            rollName varchar(255),
            datecreated date,
            isSystemRole bool 
          );
create table users (
            userId SERIAl,
            first_name varchar(50),
            last_name varchar(50),
            roleId int REFERENCES roles(roleId)
          )
insert into roles (roleId, rollName, datecreated, isSystemRole) values (1, 'Admin', '2022-02-23' , true);
insert into roles (roleId, rollName, datecreated, isSystemRole) values (2, 'Manager', '2022-02-24' , true);
insert into roles (roleId, rollName, datecreated, isSystemRole) values (3, 'Seller', '2022-02-25' , false);
insert into roles (roleId, rollName, datecreated, isSystemRole) values (4, 'Buyer', '2022-02-25' , false);
insert into roles (roleId, rollName, datecreated, isSystemRole) values (5, 'Developer', '2022-02-24' , true);
select * from roles

insert into users ( first_name, last_name, roleid) values ('Mayur', 'Patil' , 1);
insert into users ( first_name, last_name, roleid) values ('Yash', 'Agarwal' , 5);
insert into users ( first_name, last_name, roleid) values ('Lakshay', 'Akar' , 2);
insert into users ( first_name, last_name, roleid) values ('Riya', 'Gupta' , 3);
insert into users ( first_name, last_name, roleid) values ('Anshay', 'Rastogi' , 3);
insert into users ( first_name, last_name, roleid) values ('Aditi', 'Sharma' , 4);
insert into users ( first_name, last_name, roleid) values ('Daksh', 'Bindal' , 4);
select * from users

select users.*,roles.rollName from roles INNER JOIN users ON roles.roleid=users.roleid

CREATE OR REPLACE VIEW userdetails
          as
            select users.*, roles.rollName, roles.isSystemRole from roles
            INNER JOIN users
            ON roles.roleid=users.roleid;

select * from userdetails

create table category (
            cat_id INT PRIMARY KEY,
            cat_name varchar(50)
          );

insert into category ( cat_id, cat_name) values (1,'Toys');
insert into category ( cat_id, cat_name) values (2,'Clothes');
insert into category ( cat_id, cat_name) values (3,'Footwear');
insert into category ( cat_id, cat_name) values (4,'Electronics');
insert into category ( cat_id, cat_name) values (5,'Beauty');

select * from category;

create table product (
            prod_id INT PRIMARY KEY,
            prod_name varchar(50),
            prod_price INT NOT NULL,
			prod_quantity INT NOT NULL,
            cat_id int REFERENCES category(cat_id)
          );

insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (1,'Chess', 300 ,5 ,1);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (2,'Ball', 200 ,10 ,1);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (3,'Jeans', 900 ,3 ,2);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (4,'T-shirt', 150 ,15 ,2);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (5,'Crocs', 1500 ,2,3);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (6,'Shoes', 2000 ,5 ,3);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (7,'Earphones', 300 ,9 ,4);
insert into product ( prod_id,prod_name,prod_price,prod_quantity,cat_id) values (8,'Facewash', 90 ,20 ,5);

select * from product;

create table manage_order (
            order_id SERIAL PRIMARY KEY,
			prod_id int REFERENCES product(prod_id),
			order_quantity INT NOT NULL,
            time_ TIMESTAMP NOT NULL
          );

create table manage_order_audit (
            audit_order_id SERIAL PRIMARY KEY,
			prod_id int REFERENCES product(prod_id),
			order_quantity_before INT ,
			order_quantity_after INT ,
            edit_date TIMESTAMP NOT NULL
          );

CREATE OR REPLACE FUNCTION fn_order_changes_log()
        RETURNS TRIGGER
        LANGUAGE PLPGSQL
        as 
		$$
          BEGIN
              
            insert into manage_order_audit(prod_id,order_quantity_before,order_quantity_after,edit_date) values(new.prod_id,NULL,new.order_quantity,NOW());
            update product set prod_quantity = prod_quantity-new.order_quantity where prod_id=new.prod_id;
            RETURN NEW;
          END;
        $$;
		
CREATE TRIGGER triggers_order_changes
        -- BEFORE|AFTER|INSTEAD INSERT|UPDATE|DELETE|TRUNCATE|
        AFTER INSERT
        ON manage_order
        FOR EACH ROW
          EXECUTE PROCEDURE fn_order_changes_log();

insert into manage_order(prod_id,order_quantity,time_) values(2,5,NOW());
select * from product;
select * from manage_order;
select * from manage_order_audit;

insert into manage_order(prod_id,order_quantity,time_) values(7,4,NOW());

CREATE OR REPLACE FUNCTION fn_order_update_log()
        RETURNS TRIGGER
        LANGUAGE PLPGSQL
        as 
		$$
          BEGIN
            if NEW.order_quantity <> OLD.order_quantity THEN 
            insert into manage_order_audit(prod_id,order_quantity_before,order_quantity_after,edit_date) values(new.prod_id,old.order_quantity,new.order_quantity,NOW());
            update product set prod_quantity = prod_quantity-(new.order_quantity-old.order_quantity) where prod_id=new.prod_id;
			END IF;
            RETURN NEW;
          END;
        $$;
		
CREATE TRIGGER triggers_order_update
        -- BEFORE|AFTER|INSTEAD INSERT|UPDATE|DELETE|TRUNCATE|
        BEFORE UPDATE
        ON manage_order
        FOR EACH ROW
          EXECUTE PROCEDURE fn_order_update_log();
		  
update manage_order set order_quantity=3 where order_id=1;
select * from product;
select * from manage_order;
select * from manage_order_audit;

CREATE OR REPLACE FUNCTION fn_order_delete_log()
        RETURNS TRIGGER
        LANGUAGE PLPGSQL
        as 
		$$
          BEGIN
            insert into manage_order_audit(prod_id,order_quantity_before,order_quantity_after,edit_date) values(old.prod_id,old.order_quantity,0,NOW());
            update product set prod_quantity = prod_quantity+(old.order_quantity) where prod_id=old.prod_id;
            RETURN NEW;
          END;
        $$;
		
CREATE TRIGGER triggers_order_delete
        -- BEFORE|AFTER|INSTEAD INSERT|UPDATE|DELETE|TRUNCATE|
        AFTER DELETE
        ON manage_order
        FOR EACH ROW
          EXECUTE PROCEDURE fn_order_delete_log();
		  
DELETE FROM manage_order WHERE order_id = 1;  
select * from product;
select * from manage_order;
select * from manage_order_audit;