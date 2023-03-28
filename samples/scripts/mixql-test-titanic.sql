let engine "sqlite-local";
let a = (select  count(who) from Observation t1 join who t2 on t1.who_id = t2.who_id);
print($a);
