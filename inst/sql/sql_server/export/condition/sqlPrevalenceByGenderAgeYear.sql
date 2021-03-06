  select c1.concept_id as concept_id,  
    c1.concept_name as concept_name,
  	cast(cast(num.stratum_4 as int)*10 as varchar) + '-' + cast((cast(num.stratum_4 as int)+1)*10-1 as varchar) as trellis_name, --age decile
  	c2.concept_name as series_name,  --gender
  	num.stratum_2 as x_calendar_year,   -- calendar year, note, there could be blanks
  	round(1000*(1.0*num.count_value/denom.count_value),5) as y_prevalence_1000pp  --prevalence, per 1000 persons
  from 
  	(select * from ACHILLES_results where analysis_id = 404) num
  	inner join
  	(select * from ACHILLES_results where analysis_id = 116) denom
  	on num.stratum_2 = denom.stratum_1  --calendar year
  	and num.stratum_3 = denom.stratum_2 --gender
  	and num.stratum_4 = denom.stratum_3 --age decile
  	inner join
  	@cdmSchema.dbo.concept c1
  	on num.stratum_1 = CAST(c1.concept_id AS VARCHAR)
  	inner join
  	@cdmSchema.dbo.concept c2
  	on num.stratum_3 = CAST(c2.concept_id AS VARCHAR)
  where c2.concept_id in (8507, 8532)
ORDER BY c1.concept_id, CAST(num.stratum_2 as INT)