SELECT 
  tj.trolley_id,
  mc.name trolley_name,
  mc.rfid_epc trolley_epc,
  sr.recipe ->'tempering_temperature' as set_temperature,
  ttl.tray_id as trays
FROM 
tempering_jobs tj 
LEFT JOIN material_carriers mc ON mc.id =tj.trolley_id 
LEFT JOIN tempering_trolley_log ttl ON ttl.trolley_id =tj.trolley_id 
LEFT JOIN production_orders po ON po.id = ttl.production_order_id 
LEFT  JOIN  sach_revisions sr ON sr.master_sach_id = po.master_sach_id 
WHERE tj.completed_on IS NOT NULL AND sr.master_process_id = $1 AND ttl.trolley_id=$2 and tj.status is true 

select 
tj.trolley_id
--ttl.tray_id
from tempering_jobs tj 
LEFT JOIN tempering_trolley_log ttl ON ttl.trolley_id = tj .trolley_id 
WHERE tj.trolley_id = 1676


SELECT * FROM tempering_jobs tj WHERE tj.trolley_id = 1676


SELECT
      ttl.production_order_id,
      ttl.trolley_id
    FROM tempering_trolley_log ttl
    WHERE ttl.trolley_id IN (
      SELECT
        ttl.trolley_id
      FROM tempering_trolley_log ttl
      JOIN material_carriers mc ON (mc.id = ttl.trolley_id)
      WHERE ttl.production_order_id = $1
      ORDER BY ttl.id LIMIT 1
    )


SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    LEFT JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    LEFT JOIN master_lead_spaces ls ON ls.id = po.master_lead_space_id
    WHERE
      sam.machine_ids IN (ARRAY[$1::INTEGER]) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
    ORDER BY po.id
    
    
    
   select mm.id,msn.sach_no  ,mm.material_code , mm.material_type ,mm.material_specification ->'material_id' as material_id, mm.material_specification->'material_name' as material_name from master_materials mm 
   inner join master_sach_nos msn on msn.id = mm.master_sach_id  
   where mm.master_sach_id = 2
   
   
   select 
   sr.spc_tolerance ->'mid_length'->'min' as mid_length_min,
   sr.spc_tolerance ->'mid_length'->'max' as mid_length_max
   from sach_revisions sr 
   where master_sach_id =2 and master_process_id =10
   
   
   WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2
    ORDER BY mt.id
    
    
    SELECT 
      sr.spc_tolerance ->'inner_length'->'min' as inner_length_min,
      sr.spc_tolerance ->'inner_length'->'max' as inner_length_max,
      sr.spc_tolerance ->'mid_length'->'min' as mid_length_min,
      sr.spc_tolerance ->'mid_length'->'max' as mid_length_max,
      sr.spc_tolerance ->'outer_length'->'min' as outer_length_min,
      sr.spc_tolerance ->'outer_length'->'max' as outer_length_max
    FROM sach_revisions sr 
    WHERE master_sach_id =$1 AND master_process_id = $2
    
    select name from machine_tags mt where machine_id =10 and tag_group_id =3
    
   UPDATE
            ms_wheel_log 
        SET
            la = true,
            la_loaded_on = CURRENT_TIMESTAMP,
            loaded_by = 2
        WHERE
            master_sach_id = 1 AND production_order_id= 2 and master_carrier_id = 401
            
            
INSERT INTO public.ms_wheel_log
(master_carrier_id, master_sach_id, production_order_id, la,la_loaded_on,loaded_by, machine_id)
VALUES(401, 1, 2, true,current_timestamp,1, 10);

select sr.recipe->'G1' as g1_material from sach_revisions sr 

SELECT
      recipe-> 'G1' AS g1_material,
      recipe-> 'G2' AS g2_material
    FROM
      sach_revisions
    WHERE 
      master_sach_id = 2 AND master_process_id = 10
      
      
SELECT
      wc.id wc_id,
      wc.web_client_name wc_name,
      m.id m_id,
      m.machine_name m_name,
      concat( m.channel_name, '.' , m.machine_name ) machine_prefix,
      mp.id station_id,
      mp.process_number station_no,
      mp.process_name station_name,
      mp.app_url station_url
    FROM ${tableName} wc
    LEFT JOIN machines m ON (m.web_client_id = wc.id AND m.is_published = TRUE)
    LEFT JOIN master_processes mp ON (mp.id = m.master_process_id AND mp.is_published = TRUE)
    WHERE wc.ip_ipv4 = $1
      AND wc.is_published = true
      
      
SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    LEFT JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    LEFT JOIN master_lead_spaces ls ON ls.id = po.master_lead_space_id
    WHERE
      -- sam.machine_ids IN (ARRAY[$1::INTEGER]) AND
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
    ORDER BY po.id
    
SELECT id, alternate_option, master_material_film_id, cf_code, spray_material, is_published, created_on, created_by, deleted_on, deleted_by, material_specification, material_type, master_sach_id, material_code
FROM public.master_materials;

WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2
    ORDER BY mt.id
    
    
    with material as (
    SELECT  
        mm.id,msn.sach_no ,mm.material_code , 
        mm.material_type ,material.key as field,
        mm.material_specification.value
    FROM 
        master_materials mm
        INNER JOIN master_sach_nos msn ON msn.id = mm.master_sach_id
    WHERE
        mm.master_sach_id = $1
    )
    select material
    
    
SELECT
      sr.recipe->'tape_details'->'tape_color' AS tape_color,
      sr.recipe->'tape_details'->'tape_name' AS tape_name
    FROM sach_revisions sr
    WHERE sr.master_sach_id = $1 AND is_published IS true
    
    
    select recipe 
    from sach_revisions sr
    join jsonb_each_text(recipe->'spray_cycles') as cycles on true
    where sr.master_process_id = 10
    
    	SELECT sprays.*
      FROM sach_revisions sr
      left JOIN pg_catalog.jsonb_array_element_text(recipe->'spray_cycles', 1) sprays ON true
      WHERE sr.master_sach_id = 2 AND sr.master_process_id = 10
      
      
SELECT 
	sub.*
FROM  (
  SELECT
    mps.id,
    mps.stage_name,
    mps.order_num
  FROM master_process_stages mps
  WHERE mps.master_process_id = 7
    AND is_published IS TRUE
) sub
LEFT JOIN LATERAL (
  SELECT
    ppsl.*
  FROM po_process_stage_logs ppsl, production_orders po
  where po.id = 5 AND ppsl.production_order_id = 5
) ppsl ON ppsl.master_process_stage_id = sub.id
    WHERE ppsl.completed_on IS null
--    AND sub.id NOT IN (
--      SELECT
--        mps.id
--      FROM master_process_stages mps
--      WHERE mps.master_process_id = 7
--        AND is_published IS TRUE
--        ORDER BY order_num DESC LIMIT 1
--    )
    ORDER BY sub.order_num 
     LIMIT 1
    
     
     SELECT
          id
        FROM master_processes mp
        WHERE is_published IS TRUE AND id > 7
        ORDER BY process_number LIMIT 1
        
INSERT INTO public.production_orders (po_number,po_type,master_sach_id,master_lead_space_id,box_size,target_quantity,pmt_delay_weeks,current_master_process_id,remarks,is_capa_raised,planned_on,completed_on,created_on,created_by) VALUES
	 (122273365,'New',1,1,'A973-C62',24000,2,5,NULL,NULL,NULL,NULL,'2022-10-13 12:05:43.554603+05:30',NULL),
	 (456273365,'New',2,3,'A973-C90',36000,2,10,NULL,NULL,NULL,NULL,'2022-10-13 12:05:43.554603+05:30',NULL),
	 (789273365,'New',2,3,'A973-C90',36000,2,8,NULL,NULL,NULL,NULL,'2022-10-13 12:05:43.554603+05:30',NULL),
	 (122876689,'new',7,3,'A',7000,0,7,NULL,NULL,NULL,NULL,'2022-10-17 14:59:27.677522+05:30',NULL);

	
	
	
	SELECT sprays.*
      FROM sach_revisions sr
      left JOIN pg_catalog.jsonb_array_elements_text(recipe->'spray_cycles') sprays ON true
      WHERE sr.master_sach_id = 2 AND sr.master_process_id = 10
      
      
  select recipe->'spray_cycles' as spray_cycle
  from sach_revisions sr
  
 SELECT 
          production_order_id,
          la_loaded_on,
          g1_loaded_on,
          g2_loaded_on,
          machine_id,
          mc.name
          from wheel_spray_cycles wsc 
          left join material_carriers mc on mc.id = wsc.master_carrier_id 
        WHERE
          machine_id = $1 AND master_carrier_id = $2
          
INSERT INTO public.wheel_spray_cycles
(master_carrier_id, production_order_id, la_loaded_on, loaded_by, machine_id)
VALUES(407, 1, now(), 1, 7);

select 
--	substring((mc.name),1,24),
	count(*) as sides_done
from wheel_spray_cycles wsc
join material_carriers mc on mc.id = wsc.master_carrier_id 
where wsc.machine_id = 10 and wsc.production_order_id = 1 and wsc.g2_loaded_on is not null
--group by substring((mc.name),1,24)


select 
	substring(mc.name, 1, 24) as name
from wheel_spray_cycles wsc 
join material_carriers mc on mc.id = wsc.master_carrier_id 
where wsc.master_carrier_id = 405



select count(*) 
from wheel_spray_cycles wsc
where 
	production_order_id = 1 and
	machine_id = 10 and
	g2_loaded_on is not null and
	master_carrier_id  in (select id from material_carriers mc where mc."name" like 'N_DC-AUTO_MSK_Bobbin_003%')
	
	


select count(*) 
from wheel_spray_cycles wsc
where 
	production_order_id = 1 and
	machine_id = 10 and
	g2_loaded_on is not null and
	master_carrier_id  in (
		select id from material_carriers mc where mc."name" like '%' || (
			select 
				substring(mc.name, 1, 24) as name
			from wheel_spray_cycles wsc 
			join material_carriers mc on mc.id = wsc.master_carrier_id 
			where wsc.master_carrier_id = 406 and
				production_order_id = 1 and
				machine_id = 10
		) || '%'
	)
	
	
	
with required_materials as(
	select 	
	--	mm.id material_id,
		mm.material_specification->>'material_name' as material_name,
		mm.material_code
	from master_materials mm
	join production_orders po on po.current_master_process_id  = any( mm.master_process_ids )
	where po.current_master_process_id  = 10
	and mm.material_specification->>'material_name' = 'zinc_wire'
)
select * from required_materials


select cls.*
from sach_revisions sr
left join jsonb_array_elements_text(recipe->'spray_cycles' ) as cls on true
where master_sach_id = 8 and 
	master_process_id = 10
	
	
select distinct on (mul.material_id)
	mul.*
from material_usage_logs mul 
where mul.production_order_id = 2 and mul.machine_id = 10

	
with req as (
	select 
		id,
		material_code, 
		material_specification->>'diameter' wire_diameter 
	from master_materials mm 
	where mm.id in (
		select unnest (materials_ids) mids
		from sach_allowed_materials sam
		where sam.sach_id = 8 and sam.process_id = 10
	)
), actual as (
	select 
		id,
		material_code, 
		material_specification->>'diameter' wire_diameter 
	from master_materials mm 
	where mm.id in (
		select distinct on (mul.material_code)
			mul.material_id 
		from material_usage_logs mul 
		where mul.production_order_id = 2 and mul.machine_id = 10
	)
)
select
	req.id as req_id,
	req.material_code as req_m_code,
	req.wire_diameter as req_w_dia,
	actual.id as act_id,
	actual.material_code as act_m_code,
	actual.wire_diameter as act_w_dia
from req, actual


	join master_materials mm on mm.id = mul.material_id 
	join production_orders po on po.id = mul.production_order_id 
	where mul.production_order_id = 2 and mul.machine_id = 10
--	group by mul.id, mm.material_specification->>'material_name', mul.material_code
	order by mm.material_specification->>'material_name', mul.id desc limit 4

--select * from master_materials mm 
--where 10 = any(master_process_ids)
--and material_type = 'wire'

with active_materials as (
	select distinct on (mm.material_specification->>'material_name')
	--	mul.machine_id ,
		mm.material_specification->>'material_name' as material_name,
		mul.material_code
--		mul.material_id 
	from material_usage_logs mul 
	join master_materials mm on mm.id = mul.material_id 
	join production_orders po on po.id = mul.production_order_id 
	where mul.production_order_id = 2 and mul.machine_id = 10
--	group by mul.id, mm.material_specification->>'material_name', mul.material_code
	order by mm.material_specification->>'material_name', mul.id desc limit 4
)
select * from active_materials


UPDATE public.material_carrier_usage_logs
SET  disassociated_by=0, disassociated_on=''
WHERE id=nextval('material_carrier_usage_logs_id_seq'::regclass);
 



-- public.master_spc_schedules definition

-- Drop table

-- DROP TABLE public.master_spc_schedules;

CREATE TABLE public.master_spc_schedules (
	id serial4 NOT NULL,
	master_process_id int2 NULL,
	spc_type varchar(20) NULL,
	element_count int4 NULL,
	is_published bool NULL DEFAULT false,
	CONSTRAINT master_spc_schedules_pkey PRIMARY KEY (id)
);


-- public.master_spc_schedules foreign keys

ALTER TABLE public.master_spc_schedules ADD CONSTRAINT master_spc_schedules_master_process_id_fkey FOREIGN KEY (master_process_id) REFERENCES public.master_processes(id) ON DELETE RESTRICT ON UPDATE RESTRICT;


INSERT INTO public.master_spc_schedules 
      (master_process_id, spc_type, element_count, is_published) 
    VALUES
      (1, 'SETUP', 10, true),
      (1, 'STANDARD', 2000, true),
      (7, 'SETUP', 10, true),
      (7, 'STANDARD', 2000, true)
      
      
select 
mss.spc_type ,
mss.element_count 
from master_spc_schedules mss 
join spc_schedule_count ssc on ssc.master_spc_schedule_id  = mss.id 
where mss.element_count not in (select element_count from master_spc_schedules mss2)

select 
mss.spc_type,
mss.element_count
from master_spc_schedules mss 
where mss.element_count not in (select element_count from spc_schedule_log ssl)
order by mss.element_count asc
limit 1

SELECT
      wc.id wc_id,
      wc.web_client_name wc_name,
      m.id m_id,
      m.machine_name m_name,
      concat( m.channel_name, '.' , m.machine_name ) machine_prefix,
      mp.id station_id,
      mp.process_number station_no,
      mp.slug,
      mp.process_name station_name,
      mp.app_url station_url
    FROM web_clients wc 
    JOIN master_processes mp ON (mp.id = wc.master_process_id)
    LEFT JOIN machines m ON (m.web_client_id = wc.id AND m.is_published = TRUE)
    WHERE
      wc.ip_ipv4 = '192.168.205.134' AND
      wc.is_published = TRUE AND
      mp.is_published = true
      
      
 SELECT  
            mss.spc_type,
            mss.element_count
        FROM master_spc_schedules mss
        WHERE master_process_id = $1
        ORDER BY mss.element_count asc

        
INSERT INTO public.spc_visual_result
(poid, sachid, machine_id, attempt, visual_params, results)
if 
VALUES(0, 0, 0, 0, 0, '');


with svr_result as 
(select 
svr.poid ,
svr.sachid ,
svr.machine_id ,
svr.attempt 
from spc_visual_result svr)
select svr_result.attempt from svr_result

SELECT
    *,
    CASE
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL
        THEN 'g2'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NULL
        THEN 'g1'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NULL AND g2_loaded_on IS NULL
        THEN 'la'
    END AS loaded_on
    FROM wheel_spray_cycles wsc
        left join material_carriers mc on mc.id = wsc.master_carrier_id 
    WHERE 
        la_loaded_on IS NULL 
        OR g1_loaded_on IS NULL 
        OR g2_loaded_on IS NULL 
        OR completed_on IS null 
        AND wsc.machine_id = $1
        AND wsc.production_order_id = $2
    ORDER BY wsc.id LIMIT 3
    
    
    
SELECT
      mc.id,
      mc.name
    FROM material_carrier_usage_logs mcul
    LEFT JOIN material_carriers mc ON (mc.id = mcul.material_carrier_id)
    WHERE
      mcul.material_carrier_id IS NOT NULL AND
      mcul.binded_on IS NOT NULL AND
      released_on IS NULL AND
      po_id = $2 AND
      master_process_id = (
          SELECT
          CASE
            WHEN mp.process_number = 28 -- PRE_SCAN PROCESS NUMBER
            THEN (SELECT id FROM master_processes WHERE is_published IS TRUE AND process_number < mp.process_number ORDER BY process_number)
            ELSE mp.id
          END AS master_process_id
        FROM master_processes mp
        WHERE id = $1
      )
      
      
      select count(*) as count
    from wheel_spray_cycles wsc
    where 
     production_order_id = $2 and
      machine_id = $1 and
      g2_loaded_on is not null and
      master_carrier_id  in (
    select id from material_carriers mc where mc."name" like '%' || (
     select 
        substring(mc.name, 1, 24) as name
        from wheel_spray_cycles wsc 
        join material_carriers mc on mc.id = wsc.master_carrier_id 
        where wsc.master_carrier_id = $3 and
        production_order_id = $2 and
        machine_id = $1
        ) || '%'
  )
  
WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2
    ORDER BY mt.id

with req as (
	select 
		mm.id,
		mm.material_code, 
		mm.material_specification->>'diameter' wire_diameter ,
		mm.material_specification->>'material_name'  material_name,
		sr.recipe ->'spray_cycles_sequence'->0->'loc' as location,
		sr.recipe ->'spray_cycles_sequence'->1->'loc' as location2,
		sr.recipe ->'spray_cycles_sequence'->'sq1'->'mat' as material
	from master_materials mm 
	join sach_revisions sr on sr.master_process_id = any (mm.master_process_ids)
	where mm.id in (
		select unnest (materials_ids) mids
		from sach_allowed_materials sam
		where sam.sach_id = 2 and sam.process_id = 10
		limit 1
	)
), actual as (
	select 
		mm.id,
		mul.material_code, 
		material_specification->>'diameter' wire_diameter,
		mm.material_specification->>'material_name'  material_name_act
	from master_materials mm
	join material_usage_logs mul on mul.material_id =mm.id
	where mm.id in (
		select distinct on (mul.material_code)
			mul.material_id
		from material_usage_logs mul 
		where mul.production_order_id = 10 and mul.machine_id = 10
	)
)
select
	req.id as req_id,
	req.material_code as req_m_code,
	req.wire_diameter as req_w_dia,
	req.material_name as req_m_name,
	actual.material_name_act as act_m_name,
	req.location as req_w_loc,
	req.location2 as req_w_loc2,
	actual.material_code as act_m_code,
	actual.wire_diameter as act_w_dia
from req, actual

select distinct on (mul.material_code)
mul.material_code 
from material_usage_logs mul 

select 
sr.recipe ->'spray_cycles_sequence'->1->'loc' as location,
sr.recipe ->'spray_cycles_sequence'->'sq2'->'loc' as location
from sach_revisions sr

with req as (
      select
        id,
        material_code,
        material_specification->>'diameter' wire_diameter
      from master_materials mm
      where mm.id in (
        select unnest (materials_ids) mids
        from sach_allowed_materials sam
        where sam.sach_id = 2 and sam.process_id = 10
                limit 1
      )
    ), actual as (
      select
        mm.id,
        mul.material_code,
        material_specification->>'diameter' wire_diameter
      from master_materials mm
      join material_usage_logs mul on mul.material_id =mm.id
      where mm.id in (
        select distinct on (mul.material_code)
          mul.material_id
        from material_usage_logs mul
        where mul.production_order_id = 10 and mul.machine_id = 10
      )
    )
    select
      req.id as req_id,
      req.material_code as req_m_code,
      req.wire_diameter as req_w_dia,
      actual.id as act_id,
      actual.material_code as act_m_code,
      actual.wire_diameter as act_w_dia
    from req, actual


    
    
    select
        mm.id,
        material_code,
        material_specification->>'diameter' wire_diameter,
		case
--			when sr.recipe ->'spray_cycles_sequence'->0->>'sq'='1' then 'G1'
			when sr.recipe ->'spray_cycles_sequence'->1->>'sq'='2' then 'G2'
		end
      from master_materials mm
      join sach_revisions sr on sr.master_process_id =  any (mm.master_process_ids)
      where mm.id in (
        select unnest (materials_ids) mids
        from sach_allowed_materials sam
        where sam.sach_id = 2 and sam.process_id = 10
--                limit 1
      )
      
      
      
select 
sr.recipe ->'spray_cycles_sequence'->0 as sequence
from sach_revisions sr
where master_process_id =10 and sr.master_sach_id =7

select json_array_to_text_array(sr.recipe->'spray_cycles_sequence')
from sach_revisions sr 


    select
        id,
        material_code,
        material_specification->>'diameter' wire_diameter
      from master_materials mm
      where mm.id in (
        select unnest (materials_ids) mids
        from sach_allowed_materials sam
        where sam.sach_id = 2 and sam.process_id = 10
                limit 1
      )
      
      
  with  actual as (
      select
        mm.id,
        mul.material_code,
        material_specification->>'diameter' wire_diameter,
        material_specification->>'material_name' material_name
      from master_materials mm
      join material_usage_logs mul on mul.material_id =mm.id
      where mm.id in (
        select distinct on (mul.material_code)
          mul.material_id
        from material_usage_logs mul
        where mul.production_order_id = 10 and mul.machine_id = 10
      )
    )
 select 
 	  actual.id as act_id,
      actual.material_code as act_m_code,
      actual.wire_diameter as act_w_dia,
      actual.material_name as act_m_name
    from actual
    
    
    SELECT 
--		sr.recipe ->'spray_cycles_sequence' as sequence
    	cy
    FROM sach_revisions sr 
    left join pg_catalog.jsonb_array_elements_text(sr.recipe ->'spray_cycles_sequence') as cy on true
    WHERE master_process_id =10 and sr.master_sach_id =7
    
    
 select 
-- case 
-- 	when count(mcul.material_carrier_id) = count(wsc.master_carrier_id) then true
-- end
 count(wsc.master_carrier_id),
 count(mcul.material_carrier_id)
 from material_carrier_usage_logs mcul 
 join wheel_spray_cycles wsc on wsc.master_carrier_id = mcul.material_carrier_id 
 where mcul.po_id =10 and mcul.master_process_id = 10
 
 
 						-----	METAL SPRAY COMPLETED AND TOTAL COUNT ------
 with count1 as (select 
 count(mcul.material_carrier_id)
  from material_carrier_usage_logs mcul 
 join wheel_spray_cycles wsc on wsc.master_carrier_id = mcul.material_carrier_id 
 where mcul.po_id =12 and mcul.master_process_id = 12
 ),count2 as (
   select 
 count(wsc.master_carrier_id)
 from material_carrier_usage_logs mcul 
 join wheel_spray_cycles wsc on wsc.master_carrier_id = mcul.material_carrier_id 
 where mcul.po_id =12 and mcul.master_process_id = 12 and wsc.completed_on is not null
 )
 select 
 count1.count,
 count2.count
 from count1,count2
 
 
 select 
 lower ("name") 
 from machine_tags mt 
 where machine_id =159 and tag_group_id =3
 
 
   INSERT INTO public.master_scrap_reasons 
      (master_process_id, reason_text) 
    VALUES 
 ((SELECT id FROM master_processes WHERE process_number = 60 ), 'Element Film Visible'),
      ((SELECT id FROM master_processes WHERE process_number = 60 ), 'Burr on Element'),
      ((SELECT id FROM master_processes WHERE process_number = 60 ), 'Spray Damage'),
      ((SELECT id FROM master_processes WHERE process_number = 60 ), 'Missing Quantity')
      
      
      INSERT INTO public.material_carriers 
      (material_carrier_type_id, "name", master_process_ids, created_on, created_by)
    SELECT 1, CONCAT('N_DC-AUTO_ASM_BIN_', TO_CHAR(carrier, 'fm000')), '{1}', now(), 1
      FROM generate_series(1, 250, 1) carrier;
      
     
     WITH running_po AS (
      SELECT
          ppl.production_order_id, po.po_number po, msn.sach_no sach, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        LEFT JOIN master_sach_nos msn ON (po.master_sach_id = msn.id)
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
    ),
    recipe AS (
      SELECT sr.master_sach_id, running_po.po AS po, running_po.sach, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
      	WHEN lower(mt."name") = 'otp_prod_rcp_gun1_po_no'
      	THEN pr.po::TEXT
      	WHEN lower(mt."name") = 'otp_prod_rcp_gun1_sach_no'
      	THEN pr.sach::TEXT
      	WHEN lower(mt."name") = 'otp_prod_rcp_gun2_po_no'
      	THEN pr.po::TEXT
      	WHEN lower(mt."name") = 'otp_prod_rcp_gun2_sach_no'
      	THEN pr.sach::TEXT
      	ELSE pr.value
      END AS value2,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2
    ORDER BY mt.id
    
    
    select 
    wsc.id ,
    wsc.production_order_id ,
    wsc.master_carrier_id 
    from wheel_spray_cycles wsc 
    where wsc.machine_id =10 and wsc.completed_on is null
    order by id DESC 
    limit 3 
    
    
    
     INSERT INTO public.master_scrap_reasons 
      (master_process_id, reason_text) 
    VALUES    
    ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Short Mould Can'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Single Lead Rejection'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Naked Element'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Without Lead'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Extra Lead'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Joint Capacitor'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Insertion Problem'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Bursting of Element'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Off center welding'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Welding Problem'),
      ((SELECT id FROM master_processes WHERE process_number = 110 ), 'Missing Quantity');
      
     
select 
sr.recipe ->'tempering_temperature' as temp
from sach_revisions sr 
where sr.master_sach_id =2 and master_process_id =12


INSERT INTO public.material_carriers 
      (material_carrier_type_id, "name", master_process_ids, created_on, created_by)
    SELECT 3, CONCAT('N_DC-AUTO_ASM_TRAY_', TO_CHAR(carrier, 'fm000')), '{12}', now(), 1
      FROM generate_series(1, 250, 1) carrier;
      
     
     SELECT
      id, name
    FROM material_carriers mc
    WHERE $1 = ANY(master_process_ids)
      AND id NOT IN (
        SELECT material_carrier_id  FROM material_carrier_usage_logs mcul
        WHERE mcul.binded_on IS NOT NULL AND released_on IS NULL
      )
      
      
      UPDATE machine_tags SET display_name = REPLACE(substring("name", 14), '_', ' ')
WHERE machine_id = 10 and tag_group_id = 3



SELECT REPLACE(substring("name", 14), '_', ' ')  FROM machine_tags mt
WHERE machine_id = 10 and tag_group_id = 3

select 
lower (name) from machine_tags mt 
WHERE machine_id = 10 and tag_group_id = 3

 SELECT
      mc.id, mc.name, mc.rfid_epc
    FROM material_carriers mc
    WHERE $1 = ANY(master_process_ids)
      AND mc.id NOT IN (
        SELECT material_carrier_id  FROM material_carrier_usage_logs mcul
        WHERE mcul.binded_on IS NOT NULL AND released_on IS null and mcul.master_process_id = $1
      )
      
      
      
      SELECT
      mc.id,
      mc.name,
      mc.rfid_epc
    FROM material_carrier_usage_logs mcul
    LEFT JOIN material_carriers mc ON (mc.id = mcul.material_carrier_id)
    WHERE
      mcul.material_carrier_id IS NOT NULL AND
      mcul.binded_on IS NOT NULL AND
      released_on IS NULL AND
      po_id = $2 AND
      master_process_id = (
          SELECT
          CASE
            WHEN mp.process_number = 12 -- PRE_SCAN PROCESS NUMBER
            THEN (SELECT id FROM master_processes WHERE is_published IS TRUE AND process_number < mp.process_number ORDER BY process_number)
            ELSE mp.id
          END AS master_process_id
        FROM master_processes mp
        WHERE mp.id = $1
      )
      
      
      select 
      sr.spc_tolerance ->'tensile_strength' as tensile_strength
      from sach_revisions sr 
      where sr.master_sach_id = 1
      
      
      
TRUNCATE TABLE public.material_carrier_usage_logs CONTINUE IDENTITY CASCADE;
TRUNCATE TABLE public.material_usage_logs CONTINUE IDENTITY CASCADE;
TRUNCATE TABLE public.po_scrap_logs CONTINUE IDENTITY CASCADE;

TRUNCATE TABLE public.po_process_logs CONTINUE IDENTITY CASCADE;
TRUNCATE TABLE public.po_process_stage_logs CONTINUE IDENTITY CASCADE;



INSERT INTO public.spc_visual_result
(poid, sachid, machine_id, attempt, visual_params, results)
VALUES(0, 0, 0, 0, 0, '{
  "sample1": {
    "left": 5,
    "right": 6
  }
}');



SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      no_of_element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    LEFT JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    LEFT JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    WHERE
      -- sam.machine_ids IN (ARRAY[$1::INTEGER]) AND
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
    ORDER BY po.id
    
    
    select 
    ttl.id ,
    ttl.machine_id ,
    ttl.trolley_id ,
    ttl.tray_id 
    from tempering_trolley_log ttl 
    where ttl.trolley_id =1
    
     
        select 
    ttl.id ,
    ttl.machine_id ,
    ttl.trolley_id ,
    mc.rfid_epc 
    from tempering_trolley_log ttl 
    join material_carriers mc on mc.id = ttl.trolley_id 
    where ttl.machine_id  =6
    
    SELECT  
            mss.spc_type,
            mss.element_count
        FROM master_spc_schedules mss
        WHERE master_process_id = 7
        ORDER BY mss.element_count asc
    
      WITH films AS (
      SELECT msn.allowed_film_ids AS film_ids
      FROM production_orders po
      JOIN master_sach_nos msn ON msn.id = po.master_sach_id
      WHERE current_master_process_id = $1 AND po.id = $2
    )
    SELECT
      id, film_code, remark, details->>'po' as film_po
    FROM master_material_films mmf, films
    WHERE id = ANY(films.film_ids) AND
      is_published IS TRUE
      
      INSERT INTO public.master_scrap_reasons 
      (master_process_id, reason_text) 
    VALUES
      ((SELECT id FROM master_processes WHERE process_number = 65 ), 'Shrinkage Element'),
      ((SELECT id FROM master_processes WHERE process_number = 65 ), 'Element Buldge')
      
      
      
      
        WITH films AS (
      SELECT msn.allowed_film_ids AS film_ids
      FROM production_orders po
      JOIN master_sach_nos msn ON msn.id = po.master_sach_id
      WHERE current_master_process_id = $1 AND po.id = $2
    )
    SELECT
      id, film_code, remark, details->>'po' as film_po
    FROM master_material_films mmf, films
    WHERE id = ANY(films.film_ids) AND
      is_published IS TRUE
      
      
    SELECT 
        mm.id,
        mm.material_code as film_code,
        mm.material_specification->>'po' film_po,
        mm.material_specification->>'remark' remark
      FROM master_materials mm
      WHERE  mm.id in (
        SELECT  unnest (materials_ids) mids
        FROM sach_allowed_materials sam
        WHERE  sam.sach_id = 2 AND  sam.process_id = 1
                LIMIT  1)
                
                
      select 
      ttl.trolley_id 
      from tempering_trolley_log ttl 
      where ttl.production_order_id = 13
     Limit 1
     
     select 
     DISTINCT (ttl.production_order_id) 
     from tempering_trolley_log ttl 
     join production_orders po on (po.id = ttl.production_order_id)
     where ttl.trolley_id =1671
     
     select * from masking_wheel_operation mwo 
     
     insert into masking_wheel_operation_log 
     (production_order_id,wheel_carrier_id,wheel_operation_id,logged_on) values (10,401,2,current_timestamp)
     
     delete from material_carrier_usage_logs 
     where po_id =10 and master_process_id =7 and material_carrier_id =401
     
     
     
      select count(*) as count
    from wheel_spray_cycles wsc
    where 
     production_order_id = $2 and
      machine_id = $1 and
      g2_loaded_on is not null and
      master_carrier_id  in (
    select id from material_carriers mc where mc."name" like '%' || (
     select 
        substring(mc.name, 1, 24) as name
        from wheel_spray_cycles wsc 
        join material_carriers mc on mc.id = wsc.master_carrier_id 
        where wsc.master_carrier_id = $3 and
        production_order_id = $2 and
        machine_id = $1
        ) || '%'
  )
  
  with wheel as (select id from material_carriers mc where mc."name" like '%' ||(
  select 
 substring(mc.name,1,24) as name,
 mc.id,
 rfid_epc 
  from  material_carrier_usage_logs mcul 
  join material_carriers mc on mc.id = mcul .material_carrier_id 
  where mcul.material_carrier_id =403
  )||'%'
  
  
  
  
  select
        id,
        material_code,
        material_specification->>'material_name' material_name,
        material_specification->'tape_colors' as tape_colors
      from master_materials mm
      where mm.id in (
        select unnest (materials_ids) mids
        from sach_allowed_materials sam
        where sam.sach_id = 2 and sam.process_id = 7
      )
      
      
      
      select * from masking_wheel_operation mwo
      
SELECT
    *,
    CASE
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL
        THEN 'g2'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NULL
        THEN 'g1'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NULL AND g2_loaded_on IS NULL
        THEN 'la'
    END AS loaded_on
    FROM wheel_spray_cycles wsc
        left join material_carriers mc on mc.id = wsc.master_carrier_id 
    WHERE 
        (la_loaded_on IS NULL 
        OR g1_loaded_on IS NULL 
        OR g2_loaded_on IS NULL 
        OR completed_on IS null) 
        AND wsc.machine_id = $1
        AND wsc.production_order_id =  ( select ppl.production_order_id  from po_process_logs ppl where ppl.machine_id =10
    order by ppl.id DESC  
    limit 1)
    ORDER BY wsc.id LIMIT 3	
    
    
 WITH active_wheels AS (
    SELECT * FROM wheel_spray_cycles wsc
    WHERE (wsc.la_loaded_on IS NULL OR wsc.g1_loaded_on IS NULL OR wsc.g2_loaded_on IS NULL OR wsc.completed_on IS NULL)
    AND machine_id =$1
    ORDER BY id LIMIT 3
),
reindexed AS (
    SELECT
        aw.id,
        CASE WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL AND completed_on IS NULL
        THEN now()
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL AND completed_on IS NOT NULL
        THEN completed_on
        END AS completed_on,
        CASE WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NULL
        THEN now()
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL
        THEN g2_loaded_on
        END AS g2_loaded_on,
        CASE WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NULL
        THEN now()
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL
        THEN g1_loaded_on
        END AS g1_loaded_on
        FROM active_wheels aw
        )
        UPDATE wheel_spray_cycles
        SET
          g1_loaded_on = re_i.g1_loaded_on,
          g2_loaded_on = re_i.g2_loaded_on,
          completed_on = re_i.completed_on
        FROM reindexed AS re_i
        WHERE wheel_spray_cycles.id = re_i.id and machine_id =$1
        
        
        
select count(*) as count
    from wheel_spray_cycles wsc
    where 
      machine_id = $1 and
      g2_loaded_on is not null and
      master_carrier_id  in (
    select id from material_carriers mc where mc."name" like '%' || (
     select 
        substring(mc.name, 1, 24) as name
        from wheel_spray_cycles wsc 
        join material_carriers mc on mc.id = wsc.master_carrier_id 
        where wsc.master_carrier_id = $3 and machine_id = $1
        ) || '%'
  )
  
  
  
  
  SELECT count(*) as count
    FROM wheel_spray_cycles wsc
    WHERE 
      machine_id = $1 AND
      g2_loaded_on IS NOT NULL AND
      master_carrier_id  IN (
    SELECT id FROM material_carriers mc WHERE mc."name" LIKE '%' || (
     SELECT 
        substring(mc.name, 1, 24) AS name
        FROM wheel_spray_cycles wsc 
        JOIN material_carriers mc ON mc.id = wsc.master_carrier_id 
        WHERE wsc.master_carrier_id = $2 AND
        machine_id = $1
        ) || '%'
  )
  
  
  
  WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    )
    with previous_po as(
    select 
    wsc.production_order_id , po.master_sach_id ,  po.current_master_process_id 
    from wheel_spray_cycles wsc 
    left join production_orders po on po.id = wsc.production_order_id 
    where wsc.la_loaded_on is not null and wsc.g1_loaded_on is not null and wsc.g2_loaded_on is null
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN previous_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = previous_po.master_sach_id AND sr.master_process_id = previous_po.current_master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
      	WHEN lower(mt."name") like '%otp_prod_rcp_gun1%'
      	THEN 'g1'
      	WHEN lower(mt."name") like '%otp_prod_rcp_gun2%'
      	THEN 'g2'
      END AS gun,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2 
    ORDER BY mt.id
    
    
    
SELECT
    wsc.master_carrier_id ,
    wsc.production_order_id ,
    *,
    CASE
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NOT NULL
        THEN 'g2'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NOT NULL AND g2_loaded_on IS NULL
        THEN 'g1'
        WHEN la_loaded_on IS NOT NULL AND g1_loaded_on IS NULL AND g2_loaded_on IS NULL
        THEN 'la'
    END AS loaded_on
    FROM wheel_spray_cycles wsc
        left join material_carriers mc on mc.id = wsc.master_carrier_id 
         join sach_revisions sr on sr.master_sach_id = wsc.master_sach_id
    WHERE 
        (la_loaded_on IS NULL 
        OR g1_loaded_on IS NULL 
        OR g2_loaded_on IS NULL 
        OR completed_on IS null) 
        AND wsc.machine_id = $1
        AND wsc.production_order_id = ( SELECT ppl.production_order_id  
                                      FROM po_process_logs ppl WHERE ppl.machine_id =$1
                                      ORDER BY ppl.id DESC  
                                      LIMIT 1)
        AND sr.master_process_id =10
    ORDER BY wsc.id LIMIT 3 
    
    
    
    select 
    sr.recipe ->>'product_recipe'as recipe
    from sach_revisions sr 
    where sr.master_sach_id =2 and sr.master_process_id =10 and sr.recipe ->>'product_recipe' like 'otp_prod_rcp_gun1'
    
    
    
INSERT INTO public.material_carrier_usage_logs
(material_carrier_id, machine_id, master_process_id, po_id, binded_on, binded_by, released_on, released_by, disassociated_by, disassociated_on)
VALUES(0, 0, 0, 0, CURRENT_TIMESTAMP, 0, '', 0, 0, '');


select 
mc.name
from material_carriers mc 
where mc.name like 'substring(mc.name,1,23)' and mc.id =401

INSERT INTO public.material_carrier_usage_logs
(material_carrier_id, machine_id, master_process_id, po_id, binded_on, binded_by)
with carrier_id as (
SELECT id FROM material_carriers mc WHERE mc."name" LIKE '%' || (
     SELECT 
        substring(mc.name, 1, 24) AS name
       from material_carriers mc 
		where mc.id = $1
        ) || '%'
  )
  select carrier_id.id, $2, $3, $4, CURRENT_TIMESTAMP, $5 from carrier_id

  
  insert into masking_wheel_operation_log 
     (production_order_id,wheel_carrier_id,wheel_operation_id,logged_on,logged_by,element_wheel_count) 
     with carrier_id as (
SELECT id FROM material_carriers mc WHERE mc."name" LIKE '%' || (
     SELECT 
        substring(mc.name, 1, 24) AS name
       from material_carriers mc 
		where mc.id = $1
        ) || '%'
  )
     select $2,carrier_id.id,$3,current_timestamp,$4,$5 from carrier_id
  




  
        
        
        SELECT id FROM material_carriers mc WHERE mc."name" LIKE '%' || (
     SELECT 
        substring(mc.name, 1, 24) AS name
       from material_carriers mc 
		where mc.id = 407
        ) || '%'
        
        
        
        
        
INSERT INTO public.material_carrier_usage_logs
(material_carrier_id, machine_id, master_process_id, po_id, binded_on, binded_by, disassociated_by, disassociated_on)
VALUES((select carrier_id.id from carrier_id limit 1), 10, 10, 9, CURRENT_TIMESTAMP, 1, 0, CURRENT_TIMESTAMP)

select 
substring(mc.name, 1, 24) AS name
from material_carriers mc 
where mc.id = 407



WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each(recipe->>'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    select *, pg_typeof(value) from recipe
    
    
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      pg_typeof(pr.value),
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    JOIN machines km ON (km.id = kmt.machine_id )
    JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
    JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = $1 AND kmt.tag_group_id = $2
    ORDER BY kmt.id
    
    
    INSERT INTO public.material_carrier_usage_logs
(material_carrier_id, machine_id, master_process_id, po_id, binded_on, binded_by, disassociated_by, disassociated_on)
VALUES((select carrier_id.id from carrier_id limit 1), 10, 10, 9, CURRENT_TIMESTAMP, 1, 0, CURRENT_TIMESTAMP)

select 

INSERT INTO public.master_scrap_reasons 
      (master_process_id, reason_text) 

      VALUES
((SELECT id FROM master_processes WHERE process_number = 40 ), 'Excess Spray Thickness'),
      ((SELECT id FROM master_processes WHERE process_number = 40 ), 'Less Spray Thickness'),
      ((SELECT id FROM master_processes WHERE process_number = 40 ), 'Spray Sputtering'),
      ((SELECT id FROM master_processes WHERE process_number = 40 ), 'Spray on Body'),
      
      
      ((SELECT id FROM master_processes WHERE process_number = 40 ), 'Missing Quantity')
      
      
      WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    JOIN machines km ON (km.id = kmt.machine_id )
    JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
    JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = $1 AND kmt.tag_group_id = $2
    ORDER BY kmt.id
    
    
    SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    WHERE
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
      AND po.completed_on IS NULL
    ORDER BY po.id
    
    
    
    WITH actual AS (
    SELECT
      mm.id,
      mul.material_code,
      material_specification->>'diameter' wire_diameter,
      material_specification->>'material_name' material_name
    FROM master_materials mm
    JOIN material_usage_logs mul on mul.material_id =mm.id
    WHERE mm.id in (
      SELECT distinct on (mul.material_code)
        mul.material_id
      FROM material_usage_logs mul
      WHERE mul.production_order_id = (  select production_order_id from po_process_logs ppl where master_process_id =10
  order by id desc
  limit 1) and mul.machine_id = $1
    )
  )
  SELECT
    actual.id as act_id,
    actual.material_code as act_m_code,
    actual.wire_diameter as act_w_dia,
    actual.material_name as act_m_name
  FROM actual
  
  select production_order_id from po_process_logs ppl where master_process_id =10
  order by id desc
  limit 1
  
  select jsonb_array_elements(sr.recipe -> 'spray_cycles') as cycle
  from sach_revisions sr 
  WHERE master_process_id =10 and sr.master_sach_id =2
  
  SELECT
      id,
      material_code,
      material_specification->>'diameter' wire_diameter,
      material_specification->>'material_name' material_name
    FROM master_materials mm
    WHERE mm.id in (
      SELECT unnest (materials_ids) mids
      FROM sach_allowed_materials sam
      WHERE sam.sach_id = $1 and sam.process_id = $2
      limit 2)
      
INSERT INTO public.tempering_jobs
(trolley_id, created_on)
VALUES(11212, CURRENT_TIMESTAMP);

select 
tj.trolley_id,
mc.name,
mc.rfid_epc,
ttl.production_order_id ,
po.master_sach_id ,
ttl.tray_id ,
sr.recipe ->'tempering_temperature' as set_temperature
from 
tempering_jobs tj 
left join material_carriers mc on mc.id =tj.trolley_id 
left join tempering_trolley_log ttl on ttl.trolley_id =tj.trolley_id 
left join production_orders po on po.id = ttl.production_order_id 
LEFT  JOIN  sach_revisions sr on sr.master_sach_id = po.master_sach_id 
where tj.completed_on is null and sr.master_process_id =12

select 
sr.recipe ->'tempering_temperature' as set_temperature
from sach_revisions sr 
where sr.master_process_id =12

select 
case
	when tj.completed_on is null 
	then 0
	when tj.completed_on is not null
	then 1
end as status
FROM 
tempering_jobs tj 
where tj.trolley_id =1676


select 
mcul.material_carrier_id,
mcul.po_id,
sr.recipe ->'tempering_temperature' as set_temperature
from
material_carrier_usage_logs mcul 
left join production_orders po on po.id = mcul.po_id 
left join sach_revisions sr on sr.master_sach_id = po.master_sach_id 
where mcul.material_carrier_id = 401 and sr.master_process_id =12

select 



WITH actual AS (
    SELECT
      mm.id,
      mul.material_code,
      material_specification->>'diameter' wire_diameter,
      material_specification->>'material_name' material_name
    FROM master_materials mm
    JOIN material_usage_logs mul on mul.material_id =mm.id
    WHERE mm.id in (
      SELECT distinct on (mul.material_code)
        mul.material_id
      FROM material_usage_logs mul
      WHERE mul.production_order_id = (  select production_order_id from po_process_logs ppl where master_process_id =10
  order by id asc
  limit 1) and mul.machine_id = $1
    )
  )
  SELECT
    actual.id as act_id,
    actual.material_code as act_m_code,
    actual.wire_diameter as act_w_dia,
    actual.material_name as act_m_name
  FROM actual
  
  
  select production_order_id from po_process_logs ppl where master_process_id =10
  order by id
  limit 1
  
  
  
    select 
      mcul.material_carrier_id,
      mcul.po_id,
      sr.recipe ->'tempering_temperature' as set_temperature
    from
    material_carrier_usage_logs mcul 
    left join production_orders po on po.id = mcul.po_id 
    left join sach_revisions sr on sr.master_sach_id = po.master_sach_id 
    left join master_processes mp on mp.id = sr.master_process_id 
    left join material_carriers mc on mc.id = mcul.material_carrier_id 
    where mc.rfid_epc = $1 and mp.process_number = 60
    
    
    
    
    
    
    
    
    
    SELECT 
      tj.trolley_id,
      mc.name trolley_name,
      mc.rfid_epc trolley_epc,
      sr.recipe ->'tempering_temperature' as set_temperature,
      ttl.tray_id as trays
    FROM 
    tempering_jobs tj 
    LEFT JOIN material_carriers mc ON mc.id =tj.trolley_id 
    LEFT JOIN tempering_trolley_log ttl ON ttl.trolley_id =tj.trolley_id 
    LEFT JOIN production_orders po ON po.id = ttl.production_order_id 
    LEFT  JOIN  sach_revisions sr ON sr.master_sach_id = po.master_sach_id 
    WHERE tj.completed_on IS NULL AND sr.master_process_id = 12
    
    
    SELECT
      mt.id as tag_id,
      mt.machine_id,
      mt.name,
      mt.description,
      mt.display_name,
      -- kmt.tag_group,
      mt.tag_address,
      mt.tag_datatype,
      mtd.datatype_name,
      mt.scaling_unit,
      mt.is_enabled,
      m.machine_name,
      m.channel_name,
      p.plant_name,
      p.id as plant_id
    FROM
      machine_tags mt
    LEFT JOIN machines m on (m.id=mt.machine_id)
    LEFT JOIN c_plants p on (p.id = m.plant_id)
    LEFT JOIN machine_tag_datatypes mtd on (mtd.datatype_id = mt.tag_datatype)
    WHERE
      machine_id=11 AND
      mt.deleted_on is NULL
      
      
      SELECT
      mc.id,
      mc.name,
      mct.name as carrier_type,
      mc.rfid_epc
    FROM material_carrier_usage_logs mcul
    LEFT JOIN material_carriers mc ON (mc.id = mcul.material_carrier_id)
    LEFT join material_carrier_types mct on mct.id = mc.material_carrier_type_id
    WHERE
      mcul.material_carrier_id IS NOT NULL AND
      mcul.binded_on IS NOT NULL AND
      released_on IS NULL AND
      po_id = $2
      AND
      master_process_id = (
        SELECT id
        FROM master_processes
        WHERE
          is_published IS TRUE AND
          is_show_on_batch_card IS TRUE AND
          process_number < (
            SELECT
                process_number
              FROM master_processes mp
              WHERE mp.id = $1
          )
        ORDER BY process_number DESC LIMIT 1
      )
      
      
      SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      --jsonb_text(sr.recipe -> 'spray_material') as material,
      jsonb_array_elements_text(sr.recipe -> 'spray_material') as material,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
      FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id 
    WHERE
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
      AND po.completed_on IS NULL
      AND sr.master_process_id  =13
    ORDER BY po.id
    
    
    
    SELECT
       po.id AS po_id,
       ls.id AS ls_id,
       msn.id AS sach_id,
       po.po_number,
       po.po_type order_type,
       msn.sach_no,
       element_per_wheel,
       po.target_quantity,
       ls.ls_value,
       po.box_size,
       po.pmt_delay_weeks,
       po.completed_on,
       po.is_capa_raised,
       po.remarks,
       CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
       CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
     FROM
       production_orders po
     JOIN master_sach_nos msn ON msn.id = po.master_sach_id
     JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
     JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
     LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
     WHERE
       $2 = ANY(sam.machine_ids) AND
       po.current_master_process_id = $1 AND
       po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
       AND po.completed_on IS NULL
     ORDER BY po.id
  
  
  
  select 
  mcul.material_carrier_id 
  from material_carrier_usage_logs mcul
  where mcul.po_id =13
  

  with trolley as(
  			SELECT 
            ttl.trolley_id
        FROM tempering_trolley_log ttl 
        JOIN material_carriers mc on mc.id = ttl.trolley_id 
        WHERE ttl.production_order_id  =13
        LIMIT 1
     )       
        select 
        ttl.production_order_id ,
        ttl.trolley_id 
        from tempering_trolley_log ttl 
        where ttl.trolley_id =1676
        
        
WITH poids AS (
 SELECT
      ttl.production_order_id,
      ttl.trolley_id
    FROM tempering_trolley_log ttl
    WHERE ttl.trolley_id IN (
      SELECT
        ttl.trolley_id
      FROM tempering_trolley_log ttl
      JOIN material_carriers mc ON (mc.id = ttl.trolley_id)
      WHERE ttl.production_order_id = $1
      ORDER BY ttl.id LIMIT 1
    )
 )   
SELECT 
*
FROM 
material_carrier_usage_logs mcul 
WHERE mcul.po_id = 1



SELECT 
jsonb_array_elements(ttl.tray_id)->'id' AS carrier_id
FROM 
tempering_trolley_log ttl 
WHERE ttl.production_order_id =1

SELECT *
    FROM po_process_logs ppl
    WHERE
      production_order_id = 11 AND started_on IS NOT NULL AND completed_by IS NOT NULL
      
      
      SELECT * FROM po_process_logs ppl WHERE production_order_id =11 AND started_on IS NOT NULL AND completed_on IS NOT NULL
      
      
      
      SELECT * FROM tempering_jobs tj 
      WHERE completed_on IS NOT NULL AND trolley_id = 1672 AND status IS TRUE
      
      
      UPDATE public.tempering_jobs 
    SET 
      status = $2,
      completed_on = now()
    WHERE trolley_id =$1
    
    SELECT * 
    FROM tempering_jobs tj 
    WHERE completed_on IS NOT NULL AND trolley_id = $1 AND status IS TRUE
    
        SELECT *
    FROM po_process_logs ppl
    WHERE
      production_order_id = $1 AND
      started_on IS NOT NULL AND
      completed_on IS NULL
      
      SELECT 
      count (mcul.material_carrier_id) 
      FROM 
      material_carrier_usage_logs mcul 
      WHERE mcul.po_id = 1
      

WITH count AS (
      SELECT 
      count (mcul.material_carrier_id) AS count
      FROM 
      material_carrier_usage_logs mcul 
      WHERE mcul.po_id = 1
)      
SELECT 
  tj.trolley_id,
  mc.name trolley_name,
  mc.rfid_epc trolley_epc,
  sr.recipe ->'tempering_temperature' as set_temperature,
  ttl.tray_id as trays,
  count.count,
  po.id 
FROM 
tempering_jobs tj 
LEFT JOIN count ON TRUE 
LEFT JOIN material_carriers mc ON mc.id =tj.trolley_id 
LEFT JOIN tempering_trolley_log ttl ON ttl.trolley_id =tj.trolley_id 
LEFT JOIN production_orders po ON po.id = ttl.production_order_id 
LEFT  JOIN  sach_revisions sr ON sr.master_sach_id = po.master_sach_id 
WHERE tj.completed_on IS NOT NULL AND sr.master_process_id = $1 AND tj.trolley_id=$2 AND ttl.production_order_id =1


SELECT *
FROM 
tempering_jobs tj 
WHERE tj.completed_on IS NULL  AND tj.trolley_id =1672


WITH count AS (
      SELECT 
      count (mcul.material_carrier_id) AS count
      FROM 
      material_carrier_usage_logs mcul 
      WHERE mcul.po_id = 1
) 
SELECT
      ttl.production_order_id,
      ttl.trolley_id,
      count.count
    FROM tempering_trolley_log ttl
    LEFT JOIN count ON TRUE
    WHERE ttl.trolley_id IN (
      SELECT
        ttl.trolley_id
      FROM tempering_trolley_log ttl
      JOIN material_carriers mc ON (mc.id = ttl.trolley_id)
      WHERE ttl.production_order_id = $1
      ORDER BY ttl.id LIMIT 1
    )
    
    
     
SELECT 
tj.trolley_id,
mc.name trolley_name,
mc.rfid_epc trolley_epc,
sr.recipe ->'tempering_temperature' as set_temperature,
ttl.tray_id as trays,
ttl.count,
po.id AS po_id 
FROM 
tempering_jobs tj 
LEFT JOIN material_carriers mc ON mc.id =tj.trolley_id 
LEFT JOIN tempering_trolley_log ttl ON ttl.trolley_id =tj.trolley_id 
LEFT JOIN production_orders po ON po.id = ttl.production_order_id 
LEFT  JOIN  sach_revisions sr ON sr.master_sach_id = po.master_sach_id 
WHERE tj.completed_on IS NOT  NULL AND sr.master_process_id = $1 AND tj.trolley_id=$2



WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = 12 AND
          ppl.production_order_id =$2 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    JOIN machines km ON (km.id = kmt.machine_id )
    JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
    JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = 12 AND kmt.tag_group_id = 3
    ORDER BY kmt.id
    
    
    
    
    with previous_po as(
    select 
    wsc.production_order_id , po.master_sach_id ,  po.current_master_process_id 
    from wheel_spray_cycles wsc 
    left join production_orders po on po.id = wsc.production_order_id 
    where wsc.la_loaded_on is not null and wsc.g1_loaded_on is not null and wsc.g2_loaded_on is null
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN previous_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = previous_po.master_sach_id AND sr.master_process_id = previous_po.current_master_process_id
    )
    SELECT
      mt.id,
      mt."name",
      lower(mt."name") lower_name,
      COALESCE ( mt.display_name, mt."name") AS display_name,
      mtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', mtg."name", '.', mt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(mt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(mt."name") like '%otp_prod_rcp_gun2%'
      THEN 'g2'
      END AS gun,
      COALESCE ( mt.min_value, 1) min_value,
      COALESCE ( mt.max_value, 400) max_value,
      mtd.datatype_name AS datatype,
      mt.config->>'type' AS category
    FROM machine_tags mt
    JOIN machines km ON (km.id = mt.machine_id )
    JOIN machine_tag_groups mtg ON (mtg.id = mt.tag_group_id )
    JOIN machine_tag_datatypes mtd ON (mtd.datatype_id = mt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(mt."name") )
    WHERE mt.machine_id = $1 AND mt.tag_group_id = $2 
    ORDER BY mt.id
    
    
    
    SELECT 
    tray_id 
    FROM tempering_trolley_log ttl 
    
    
    SELECT
      ttl.production_order_id,
      ttl.trolley_id,
      po.po_number 
    FROM tempering_trolley_log ttl
    WHERE ttl.trolley_id IN (
      SELECT
        ttl.trolley_id
      FROM tempering_trolley_log ttl
      JOIN material_carriers mc ON (mc.id = ttl.trolley_id)
      LEFT JOIN production_orders po ON po.id = ttl.production_order_id 
      WHERE ttl.production_order_id = $1
      ORDER BY ttl.id LIMIT 1
    )
    
    
    
    
    SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
      CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
    WHERE
      $2 = ANY(sam.machine_ids) AND
      po.current_master_process_id = $1 AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
      AND po.completed_on IS NULL
    ORDER BY po.id
    
    
    
    SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
      CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
    WHERE
      $2 = ANY(sam.machine_ids) AND
      po.current_master_process_id = $1 AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
      AND po.completed_on IS NULL
    ORDER BY po.id
    
    
    
    INSERT INTO Tbl_Batch
(PONo, POQty, SachNo, AssemblyMachine, TestingMachine, IsImpregnation, IsWashingDone)
VALUES(90600441511, 'B32921C3473M249', '', '', '', '', '');



SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      --jsonb_text(sr.recipe -> 'spray_material') as material,
--      jsonb_array_elements_text(sr.recipe -> 'spray_material') as material,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
      FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = 12 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    left JOIN sach_revisions sr ON true
    WHERE
      12 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> 12 AND started_on IS NOT NULL)
      AND po.completed_on IS NULL
      AND sr.master_process_id  =13
    ORDER BY po.id

    
    SELECT
       po.id AS po_id,
       ls.id AS ls_id,
       msn.id AS sach_id,
       po.po_number,
       po.po_type order_type,
       msn.sach_no,
       element_per_wheel,
       po.target_quantity,
       ls.ls_value,
       po.box_size,
       po.pmt_delay_weeks,
       po.completed_on,
       po.is_capa_raised,
       po.remarks,
       CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
       CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
     FROM
       production_orders po
     JOIN master_sach_nos msn ON msn.id = po.master_sach_id
     JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
     JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
     LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
     WHERE
       $2 = ANY(sam.machine_ids) AND
       po.current_master_process_id = $1 AND
       po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
       AND po.completed_on IS NULL
     ORDER BY po.id
     
     
     
     select
lower ("name")
from machine_tags mt
where machine_id =5 and tag_group_id =3


WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    JOIN machines km ON (km.id = kmt.machine_id )
    JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
    JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = $1 AND kmt.tag_group_id = $2
    ORDER BY kmt.id
    
    
    
    
    SELECT
      wc.id wc_id,
      wc.web_client_name wc_name,
      wc.machine_id,
      --m.id m_id,
      --m.machine_name m_name,
      --concat( m.channel_name, '.' , m.machine_name ) machine_prefix,
      mp.id station_id,
      mp.process_number station_no,
      mp.slug,
      mp.process_name station_name,
      mp.app_url station_url
    FROM web_clients wc
    JOIN master_processes mp ON (mp.id = wc.master_process_id)
    --LEFT JOIN machines m ON (m.web_client_id = wc.id AND m.is_published = TRUE)
    WHERE
      wc.ip_ipv4 = '192.168.225.68' AND
      wc.is_published = TRUE AND
      mp.is_published = TRUE
      
      
      
      
      SELECT
      po.id AS production_order_id,
      po.po_type,
      ppl.master_process_id,
      ppl.machine_id,
      ppl.completed_on,
      ppl.completed_by,
      po.po_number,
      po.target_quantity,
      msn.sach_no sach_number,
      ls.ls_value,
      po.box_size,
      po.remarks,
      po.pmt_delay_weeks
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    JOIN po_process_logs ppl ON ppl.production_order_id  = po.id
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = ppl.master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    WHERE
      ppl.machine_id = $1 AND
      ppl.completed_on IS NOT NULL
    ORDER BY po.id
    
    
    
    SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    WHERE
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
      AND po.completed_on IS NULL
    ORDER BY po.id
    
    
    
    
    
    SELECT
       po.id AS po_id,
       ls.id AS ls_id,
       msn.id AS sach_id,
       po.po_number,
       po.po_type order_type,
       msn.sach_no,
       element_per_wheel,
       po.target_quantity,
       ls.ls_value,
       po.box_size,
       po.pmt_delay_weeks,
       po.completed_on,
       po.is_capa_raised,
       po.remarks,
       po.current_master_process_id
       --jsonb_text(sr.recipe -> 'spray_material') as material,
    FROM sach_revisions sr WHERE po.master_sach_id  = sr.master_sach_id  )
--      COALESCE ( jsonb_array_elements_text(sr.recipe -> 'spray_material'), null) material,
--      COALESCE ( mt.max_value, 400) max_value,
--       jsonb_array_elements_text(sr.recipe -> 'spray_material') as material,
       CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
       CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
       FROM
       production_orders po
     JOIN master_sach_nos msn ON msn.id = po.master_sach_id
     LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
     JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
     JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
     left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
     WHERE
       $1 = ANY(sam.machine_ids) AND
       po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
       AND po.completed_on IS NULL
       AND sr.master_process_id  =$2
     ORDER BY po.id
     
     
     
     
     
     SELECT sub.id,
      sub.stage_name,
      sub.url_slug,
      CASE
        WHEN ppsl.started_on IS NOT NULL
        THEN 1
        ELSE 0
      END AS in_process,
      CASE
        WHEN ppsl.completed_on IS NOT NULL
        THEN 1
        ELSE 0
      END AS is_completed,
      CASE
        WHEN ppsl.completed_on IS NOT NULL
        THEN 'completed'
        WHEN ppsl.started_on IS NOT NULL
        THEN 'in_process'
        ELSE 'not_started'
      END AS stage_status
    FROM  (
        SELECT
        mps.id,
        mps.stage_name,
        mps.order_num,
        mps.url_slug
      FROM master_process_stages mps
      WHERE mps.master_process_id = $1
      AND is_published IS TRUE
    ) sub
    LEFT JOIN LATERAL (
      SELECT
        ppsl.*
      FROM po_process_stage_logs ppsl, production_orders po
      where po.id = $2 AND ppsl.production_order_id = $2
    ) ppsl ON ppsl.master_process_stage_id = sub.id
    ORDER BY sub.order_num
    
--    
--  date_part('month', timestamp)
--
--  	date_part('month', interval '2 years 3 months')
--  	
--  	
  	EXTRACT (MONTH FROM current_timestamp)
  	
  	
  	SELECT EXTRACT(month FROM Date current_timestamp)

  	
  	INSERT INTO public.videojet_logs
(production_number, sach_number, product_counter, marking_counter)
VALUES(1212122, 'B32323A2104JN1', 0, 0);

  INSERT INTO public.videojet_logs
          ($1, $2, $3, $4)
        VALUES(1212122, 'B32323A2104JN1', 0, 0);
        
       
       SELECT
       po.id AS po_id,
       ls.id AS ls_id,
       msn.id AS sach_id,
       po.po_number,
       po.po_type order_type,
       msn.sach_no,
       element_per_wheel,
       po.target_quantity,
       ls.ls_value,
       po.box_size,
       po.pmt_delay_weeks,
       po.completed_on,
       po.is_capa_raised,
       po.remarks,
       po.current_master_process_id,
       COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--       jsonb_text(sr.recipe -> 'spray_material') as material,
       jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
       CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
       --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
       FROM
       production_orders po
     JOIN master_sach_nos msn ON msn.id = po.master_sach_id
     LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
     JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
     JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
     left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
     LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
--     left join LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
     WHERE
       $1 = ANY(sam.machine_ids) AND
       po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
       AND po.completed_on IS NULL
       AND sr.master_process_id  =$2
     ORDER BY po.id
     
     
SELECT
      ttl.trolley_id
    FROM tempering_trolley_log ttl
    WHERE ttl.production_order_id = $1
    LIMIT 1
    
    
    
    SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $1 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$2
ORDER BY po.id




SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id


SELECT * FROM production_orders po WHERE id = 18



SELECT
      sr.recipe->>'lead_space_straightner' AS lead_space_straightner
    FROM sach_revisions sr
    WHERE sr.master_sach_id = $1 AND is_published IS TRUE AND sr.master_process_id=$2
    
    
    SELECT ls_name,ls_value FROM master_lead_spaces
    
    
      INSERT INTO public.users (user_role_id, email, fname, lname, username, salt, hash, profile, created_by)
    VALUES(
      4,
      'op@spd.com',
      'Internal',
      'Supervisor',
      'su',
      '2620adf1ef6d13a4270b52ad2de75878',
      '92468250fe5bca05027d015f99bcec2bc43b99d3ab9c3ef1c68d30f65db23df17b819a5eb35138d73119ebd2a1fff7c752b05edadd3328715df6de15d2535855',
      'assets/images/user.png',
      1
    )
    
    
    SELECT 
    mapt.process_name 
    FROM master_aoi_process_type mapt 
    WHERE mapt.is_published IS TRUE
    
    
    SELECT
  po.id AS po_id,
  msn.id AS sach_id,
  po.po_number,
--  po.po_type order_type,
  msn.sach_no,
--  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
--  po.pmt_delay_weeks,
--  po.completed_on,
  po.is_capa_raised,
  po.remarks,
--  po.current_master_process_id,
--  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
--  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
--JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
LEFT JOIN aoi_po_type_log aptl ON aptl.id = po.id 
--left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
--LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND po.current_master_process_id =$1
  AND po.id NOT IN (SELECT aptl.production_order_id FROM aoi_po_type_log aptl)
--  AND apl.aoi_process_type_id = (SELECT mapt.id  FROM master_aoi_process_type mapt WHERE mapt.process_name= 'AOI')
ORDER BY po.id


SELECT
    po.id AS po_id,
    msn.id AS sach_id,
    po.po_number,
    msn.sach_no,
    po.target_quantity,
    ls.ls_value,
    po.box_size,
    po.is_capa_raised,
    po.remarks,
    CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
    FROM
    production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    LEFT JOIN aoi_po_type_log aptl ON aptl.id = po.id 
    WHERE
    po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE started_on IS NOT NULL)
    AND po.completed_on IS NULL
    AND po.current_master_process_id =$1
    AND po.id IN (SELECT aptl.production_order_id FROM aoi_po_type_log aptl)
    ORDER BY po.id
    
SELECT mapd.processor_name  FROM master_aoi_processor_details mapd  


SELECT
      po.id AS po_id,
      msn.id AS sach_id,
      po.po_number,
      msn.sach_no,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.is_capa_raised,
      po.remarks,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      FROM
      production_orders po
      JOIN master_sach_nos msn ON msn.id = po.master_sach_id
      LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
      JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
      LEFT JOIN aoi_po_type_log aptl ON aptl.id = po.id 
      WHERE
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE started_on IS NOT NULL)
      AND po.completed_on IS NULL
      AND po.current_master_process_id =$1
      AND po.id IN (SELECT aptl.production_order_id FROM aoi_po_type_log aptl)
      ORDER BY po.id
      



N_DC-AUTO_TST_BIN_01


INSERT INTO public.material_carriers 
      (material_carrier_type_id, "name", master_process_ids, created_on, created_by)
    SELECT
      1 AS material_carrier_type_id, 
      (CASE 
        WHEN Length(carrier::TEXT) > 2
        THEN CONCAT('N_DC-AUTO_TST_BIN_', TO_CHAR(carrier, 'fm000'))
        ELSE CONCAT('N_DC-AUTO_TST_BIN_', TO_CHAR(carrier, 'fm00'))
      END) AS name, 
      '{1,5,18}' AS master_process_ids, 
      now() AS created_on,
      1 AS created_by
        FROM generate_series(1, 300, 1) carrier
        
        
SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  apl.stage AS aoi_stage,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
LEFT JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
LEFT JOIN aoi_process_log apl ON apl.production_order_id = po.id 
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id



INSERT INTO public.aoi_po_type_log
(production_order_id, machine_id, aoi_process_type_id, created_by, created_on)
VALUES(0, 0, 0, 0, CURRENT_TIMESTAMP);

SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  COALESCE (  (SELECT apsl.stage 
  FROM aoi_process_stage_log apsl
  ORDER BY id DESC LIMIT 1),'new') AS aoi_stage,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
LEFT JOIN aoi_process_stage_log apsl ON apsl.production_order_id = po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id

SELECT 
mapd.id ,
            mapd.processor_name  
        FROM master_aoi_processor_details mapd
        
        
        
  COALESCE
  
  SELECT apsl.stage 
  FROM aoi_process_stage_log apsl
  ORDER BY id DESC LIMIT 1
  
  
  SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  COALESCE (  (SELECT apsl.stage 
  FROM aoi_process_stage_log apsl
  ORDER BY apsl.id DESC LIMIT 1),'new') AS aoi_stage,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
LEFT JOIN aoi_process_stage_log apsl ON po.id = (SELECT apsl.production_order_id FROM aoi_process_stage_log apsl WHERE po.id = apsl.production_order_id ORDER BY apsl.id  DESC LIMIT 1) 
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id


SELECT
 
  COALESCE (  (SELECT apsl.stage 
  FROM aoi_process_stage_log apsl
  ORDER BY apsl.id DESC LIMIT 1),'new') AS aoi_stage,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
LEFT JOIN aoi_process_stage_log apsl ON apsl.production_order_id = po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id



select sum(good_bin_count) capacitor_count
from
(
    select good_bin_count
    from aoi_reject_count_post_testing arcpt 
    union all
    select good_bin_count 
    from aoi_rejected_count_pre_testing arcpt2 
) t

SELECT 
                  apsl.stage,
                  apsl.production_order_id  
              FROM 
                  aoi_process_stage_log apsl
                  WHERE APSL.production_order_id =18
              ORDER BY completed_on DESC LIMIT 1 
              
              
SELECT  
            rec_id, 
            msn.sach_no AS sach_no, 
            recipe_name, 
            top_line_1, 
            top_line_2, 
            side_line_1, 
            side_line_2, 
            enec, 
            lead_length_lower, 
            lead_length_upper, 
            camera_1_sg, 
            camera_1_sn, 
            camera_2_sg, 
            camera_2_sn, 
            camera_3_sg, 
            camera_3_sn, 
            recipename_c4, 
            recipename_c5, 
            recipename_c6, 
            recipename_c7, 
            recipename_c8, 
            recipename_c9, 
            recipename_c10
        FROM 
            public.aoi_recipe_template art
        LEFT JOIN master_sach_nos msn ON msn.id = art.master_sach_no 
        WHERE
            art.master_sach_no = $1
            
            
  DELETE FROM po_process_logs WHERE production_order_id = 8;
  
  DELETE FROM po_process_stage_logs  WHERE production_order_id = 8;

  -- What is the result?
SELECT MAX(id) FROM machine_tags mt;

SELECT nextval('machine_tags_id_seq');


BEGIN;
-- protect against concurrent inserts while you update the counter
LOCK TABLE machine_tags IN EXCLUSIVE MODE;
-- Update the sequence
SELECT setval('machine_tags_id_seq', COALESCE((SELECT MAX(id)+1 FROM machine_tags), 1), false);
COMMIT;




WITH running_po AS (
      SELECT
          ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        WHERE
          ppl.machine_id = $1 AND
          ppl.production_order_id =$2 AND
          ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
        ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      left JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    left JOIN machines km ON (km.id = kmt.machine_id )
    left JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
    left JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = $1 AND kmt.tag_group_id = $3
    ORDER BY kmt.order_num 
    
    
     SELECT
      mc.id, mc.name, mc.rfid_epc
    FROM material_carriers mc
    WHERE $1 = ANY(master_process_ids)
      AND mc.id NOT IN (
        SELECT DISTINCT  material_carrier_id  FROM material_carrier_usage_logs mcul
        LEFT JOIN masking_wheel_operation_log mwol ON mwol.wheel_carrier_id = mcul.material_carrier_id  
        WHERE mcul.binded_on IS NOT NULL AND released_on IS NULL AND mcul.disassociated_on IS NULL 
      )
      
      
SELECT 
mwol.production_order_id ,
mwol .wheel_carrier_id ,
mwol .element_wheel_count 
FROM masking_wheel_operation_log mwol 
WHERE mwol.wheel_operation_id =2 AND mwol.production_order_id = 8 AND mwol.wheel_carrier_id = 409


UPDATE material_carrier_usage_logs 
SET disassociated_on = current_timestamp 
WHERE material_carrier_id IN  (
SELECT id FROM material_carriers mc WHERE mc."name" LIKE '%' || (
     SELECT 
        substring(mc.name, 1, 24) AS name
       from material_carriers mc 
    where mc.id = $1
        ) || '%'
  )
  
  
CREATE TABLE public.tools (
    id serial4 NOT NULL,
    tool_name text NOT NULL,
    tool_specifications _float4 NULL,
    CONSTRAINT tools_pk PRIMARY KEY (id)
);


CREATE TABLE public.tool_details (
    id bigserial NOT NULL,
    process_id int4 NOT NULL,
    part_id int4 NOT NULL,
    tool_id int4 NOT NULL,
    tool_value text NOT NULL,
    value_type varchar(20) NOT NULL DEFAULT 'number'::character varying,
    created_by int4 NOT NULL,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_by int4 NULL,
    update_on timestamptz NULL,
    CONSTRAINT tool_details_pk PRIMARY KEY (id)
);


CREATE TABLE public.tool_selection_rules (
    id serial4 NOT NULL,
    process_id int4 NOT NULL,
    rule_name varchar(50) NOT NULL,
    tool_ids _int4 NOT NULL,
    created_by int4 NOT NULL,
    created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tool_selection_rules_pk PRIMARY KEY (id)
);



SELECT 
t.tool_name AS name ,
td.tool_value AS required_value,
t.tool_specifications AS list
FROM tool_details td 
LEFT JOIN tools t  ON t.id = td.tool_id 
WHERE part_id =1


SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
--      CASE
--        WHEN mp.process_number = 220
--        THEN po.taping_quantity
--        ELSE po.target_quantity
--      END AS target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      COALESCE (ttl.trolley_id,NULL) AS trolley_id,
      jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
      CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    JOIN master_processes mp ON mp.id = po.current_master_process_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
    LEFT JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
    LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
    --LEFT JOIN aoi_process_stage_log apl ON apl.production_order_id = po.id
    --LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
    WHERE
      $2 = ANY(sam.machine_ids) AND
      po.current_master_process_id = $1 AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
      AND po.completed_on IS NULL
  	  AND sr.master_process_id  =$1
    ORDER BY po.id
    
    
    
    SELECT
  po.id AS po_id,
  ls.id AS ls_id,
  msn.id AS sach_id,
  po.po_number,
  po.po_type order_type,
  msn.sach_no,
  element_per_wheel,
  po.target_quantity,
  ls.ls_value,
  po.box_size,
  po.pmt_delay_weeks,
  po.completed_on,
  po.is_capa_raised,
  po.remarks,
  po.current_master_process_id,
  COALESCE (ttl.trolley_id,NULL) AS trolley_id,
--jsonb_text(sr.recipe -> 'spray_material') as material,
  jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
  CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
--CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
  FROM
  production_orders po
JOIN master_sach_nos msn ON msn.id = po.master_sach_id
LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
left JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
--LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
WHERE
  $2 = ANY(sam.machine_ids) AND
  po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND started_on IS NOT NULL)
  AND po.completed_on IS NULL
  AND sr.master_process_id  =$1
ORDER BY po.id


SELECT 
        t.tool_name AS name ,
        td.tool_value AS required_value,
        t.tool_specifications AS list,
        td.tool_id
    FROM tool_details td 
    LEFT JOIN tools t  ON t.id = td.tool_id 
    WHERE part_id = $1
    
    
    
    
    
WITH running_po AS (
      SELECT
        ppl.production_order_id, po.master_sach_id, ppl.master_process_id
        FROM po_process_logs ppl
        LEFT JOIN production_orders po ON po.id = ppl.production_order_id
        LEFT JOIN machines m ON (m.id = ppl.machine_id)
      WHERE
        (m.id = $1 OR $1 = ANY(m.linked_machine_ids) ) AND
        ppl.started_on IS NOT NULL AND ppl.completed_on IS NULL
      ORDER BY ppl.id DESC LIMIT 1
    ),
    recipe AS (
      SELECT sr.master_sach_id, recipe.KEY AS field, recipe.value
      FROM sach_revisions sr
      LEFT JOIN running_po ON true
      JOIN jsonb_each_text(recipe->'product_recipe') recipe ON true
      WHERE sr.master_sach_id = running_po.master_sach_id AND sr.master_process_id = running_po.master_process_id
    )
    SELECT
      kmt.id,
      kmt."name",
      lower(kmt."name") lower_name,
      COALESCE ( kmt.display_name, kmt."name") AS display_name,
      kmtg."name" AS tag_group,
      concat(km.channel_name, '.', km.machine_name, '.', kmtg."name", '.', kmt.name) AS node_id,
      concat(km.channel_name, '.', km.machine_name) AS machine_prefix,
      pr.value,
      CASE 
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun1%'
        THEN 'g1'
        WHEN lower(kmt."name") like '%otp_prod_rcp_gun2%'
        THEN 'g2'
      END AS gun,
      COALESCE ( kmt.min_value, 1) min_value,
      COALESCE ( kmt.max_value, 400) max_value,
--      kmtd.datatype_name AS datatype,
      kmt.config->>'type' AS category
    FROM machine_tags kmt
    JOIN machines km ON (km.id = kmt.machine_id )
    JOIN machine_tag_groups kmtg ON (kmtg.id = kmt.tag_group_id )
--    JOIN machine_tag_datatypes kmtd ON (kmtd.datatype_id = kmt.tag_datatype)
    LEFT JOIN recipe AS pr ON ( pr.field = lower(kmt."name") )
    WHERE kmt.machine_id = $1 AND kmt.tag_group_id = $2
    ORDER BY kmt.id
    


INSERT INTO public.machine_tag_datatypes (datatype_id,datatype_name) VALUES
     (0,'string'),
     (1,'boolean'),
     (2,'char'),
     (3,'byte'),
     (4,'short'),
     (5,'word'),
     (6,'long'),
     (7,'dword'),
     (8,'float'),
     (9,'double');
     
    
    
    SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      po.target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process
      --CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $1 AND ppl2.started_on IS NOT NULL AND ppl2.completed_on IS NULL)
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    WHERE
      $1 = ANY(sam.machine_ids) AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $1 AND started_on IS NOT NULL)
      AND po.completed_on IS NULL
      AND sr.master_process_id  =$1
    ORDER BY po.id
    
SELECT
tp.id ,
tp.param_name ,
tp.sample_size ,
tp.order_num ,
tp.input_type,
tpt.min,
tpt.max
FROM test_params tp 
JOIN test_sub_type tst ON tst.id = tp.test_sub_type_id 
JOIN test_param_tolerance tpt ON tpt.test_param_id  = tp.id 
WHERE tst.id = (SELECT tst.id FROM test_sub_type tst WHERE tst."name" = $2) AND tp.process_id = $1
    
INSERT INTO public.test
(production_order_id, process_id, test_sub_type, created_by, created_on, completed_on, completed_by)
VALUES(0, 0, '', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);

SELECT 
t.id,
t.production_order_id 
FROM test t 
JOIN test_sub_type tst ON tst.id = t.test_sub_type 
WHERE t.production_order_id =122 AND t.test_sub_type = (SELECT tst.id FROM test_sub_type tst WHERE tst."name" = $2)

INSERT INTO public.test_type ("name") VALUES
     ('VISUAL_INSPECTION'),
     ('Measurement');
     
    
    SELECT *
    FROM test_result tr 
    JOIN test t ON t.test_sub_type = (SELECT tst.id FROM test_sub_type tst WHERE tst."name" = 'VISUAL')
    JOIN test_sub_type tst ON tst.id =(SELECT tst.id FROM test_sub_type tst WHERE tst."name" = 'VISUAL')
    WHERE tst."name" ='VISUAL'
    
    
    SELECT tst.id FROM test_sub_type tst WHERE tst."name" = $1
    
    
    INSERT INTO public.test
(production_order_id, process_id, test_sub_type)
VALUES(123, 1, ( SELECT tst.id FROM test_sub_type tst WHERE tst."name" = $1));

SELECT 
tr.test_param_id ,
tr.value ,
tr.min ,
tr.max ,
tr.pass ,
tr.sample ,
tr.performed_by ,
tr.performed_on 
FROM test_result tr 
LEFT JOIN test t ON t.id = tr.test_id 
LEFT JOIN test_sub_type tst ON tst.id = t.test_sub_type 
WHERE t.production_order_id =1 AND t.id =45 AND tst."name" ='VISUAL'
ORDER BY t.production_order_id DESC 

INSERT INTO test_result 
(value)

values( CASE 
 	WHEN $1 = true THEN 1
 	WHEN $1 = false THEN 0
 	ELSE $1
 END )
 
 SELECT 
 
 
 SELECT
      po.id AS po_id,
      ls.id AS ls_id,
      msn.id AS sach_id,
      po.po_number,
      po.po_type order_type,
      msn.sach_no,
      element_per_wheel,
      CASE
        WHEN mp.process_number = 220
        THEN po.taping_quantity
        ELSE po.target_quantity
      END AS target_quantity,
      ls.ls_value,
      po.box_size,
      po.pmt_delay_weeks,
      po.completed_on,
      po.is_capa_raised,
      po.remarks,
      po.current_master_process_id,
      --COALESCE (apl.stage,'new') AS aoi_stage,
      COALESCE (ttl.trolley_id,NULL) AS trolley_id,
      --jsonb_text(sr.recipe -> 'spray_material') as material,
      jsonb_array_elements_text(COALESCE (sr.recipe -> 'spray_material','[null]'::jsonb)) as material,
      mcul.material_carrier_id ,
      CASE WHEN ppl2.id IS NOT NULL THEN true ELSE false END AS po_in_process,
      CASE WHEN ppl2.id IS NOT NULL AND ppl2.setup_completed_on IS NOT NULL THEN true ELSE false END AS init_setup_done
    FROM
      production_orders po
    JOIN master_sach_nos msn ON msn.id = po.master_sach_id
    JOIN sach_allowed_machines sam ON (sam.sach_id = msn.id AND sam.process_id = po.current_master_process_id)
    JOIN master_lead_spaces ls ON ls.id = msn.master_lead_space_id
    JOIN master_processes mp ON mp.id = po.current_master_process_id
    LEFT JOIN po_process_logs ppl2 ON (ppl2.production_order_id = po.id AND ppl2.machine_id = $2 AND ppl2.started_on IS NOT NULL)
    LEFT JOIN sach_revisions sr on po.master_sach_id  = sr.master_sach_id
    LEFT JOIN tempering_trolley_log ttl ON ttl.production_order_id =po.id
    LEFT JOIN material_carrier_usage_logs mcul ON mcul.po_id = po.id 
    --LEFT JOIN aoi_process_stage_log apl ON apl.production_order_id = po.id
    --LEFT JOIN LATERAL jsonb_array_elements_text(sr.recipe -> 'spray_material') as material ON true
    WHERE
      $2 = ANY(sam.machine_ids) AND
      po.current_master_process_id = $1 AND
      po.id NOT IN (SELECT production_order_id FROM po_process_logs ppl WHERE machine_id <> $2 AND master_process_id = $1 AND started_on IS NOT NULL AND completed_on IS NULL)
      AND po.completed_on IS NULL
      AND sr.master_process_id  =$1
      AND mcul.master_process_id = $1
--      GROUP BY po.id
    ORDER BY po.id
    
    SELECT 
   count( mcul.material_carrier_id )
    FROM material_carrier_usage_logs mcul 
    WHERE mcul.po_id = 11 AND mcul.master_process_id = 10
    
    SELECT 
        tr.test_param_id ,
        tr.value ,
        tr.min ,
        tr.max ,
        tr.pass ,
        tr.sample ,
        tr.performed_by ,
        tr.performed_on 
    FROM test_result tr 
    LEFT JOIN test t ON t.id = tr.test_id 
    LEFT JOIN test_sub_type tst ON tst.id = t.test_sub_type 
    LEFT JOIN test_params tp ON tp.id = tr.test_param_id 
    WHERE t.production_order_id =$1 AND t.id =$2 AND tst."name" =$3
    
    
    
 SELECT
      mc.id,
      mc.name,
      mct.name as carrier_type,
      mc.rfid_epc
    FROM material_carrier_usage_logs mcul
    LEFT JOIN material_carriers mc ON (mc.id = mcul.material_carrier_id)
    LEFT join material_carrier_types mct on mct.id = mc.material_carrier_type_id
    WHERE
      mcul.material_carrier_id IS NOT NULL AND
      mcul.binded_on IS NOT NULL AND
      released_on IS NULL AND
      po_id = $2
      AND
      master_process_id = (
        SELECT id
        FROM master_processes
        WHERE
          is_published IS TRUE AND
          is_show_on_batch_card IS TRUE AND
          process_number < (
            SELECT
                process_number
              FROM master_processes mp
              WHERE mp.id = $1
          )
        ORDER BY process_number DESC LIMIT 1
      )


       SELECT 
      mcul.material_carrier_id ,
      sr.recipe ->'tempering_temperature' AS tray_temperature,
      --count(mcul.material_carrier_id),
      po.po_number ,
      mc.rfid_epc 
    FROM material_carrier_usage_logs mcul 
    LEFT JOIN sach_revisions sr ON sr.master_process_id = mcul.master_process_id
    LEFT JOIN production_orders po ON po.id = mcul.po_id 
    LEFT JOIN material_carriers mc ON mc.id = mcul.material_carrier_id 
    WHERE mcul.po_id = ANY($1) AND mcul.master_process_id = $2

    WITH count AS (
       SELECT 
     count(mcul.material_carrier_id )
      FROM material_carrier_usage_logs mcul 
      WHERE mcul.po_id = 8 AND mcul.master_process_id =12
      ),
      details AS (
            SELECT 
      mcul.material_carrier_id ,
      sr.recipe ->'tempering_temperature' AS tray_temperature,
      po.po_number ,
      mc.rfid_epc 
      FROM material_carrier_usage_logs mcul 
      LEFT JOIN sach_revisions sr ON sr.master_process_id = mcul.master_process_id
      LEFT JOIN production_orders po ON po.id = mcul.po_id 
      LEFT JOIN material_carriers mc ON mc.id = mcul.material_carrier_id 
      WHERE mcul.po_id =8 AND mcul.master_process_id = 12
      )
      SELECT 
      count.count AS total_count,
      details.material_carrier_id,
      details.tray_temperature,
      details.po_number,
      details.rfid_epc
      FROM count,details
      
      SELECT 
    count( po.po_number  )
     FROM material_carrier_usage_logs mcul 
     LEFT JOIN production_orders po ON po.id = mcul.po_id 
     WHERE mcul.po_id =8 AND mcul.master_process_id = 12
     
     
     INSERT INTO public.videojet_logs
        VALUES ($1)