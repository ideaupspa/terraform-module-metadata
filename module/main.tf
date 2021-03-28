locals {
  
  default_properties = {
	label_order         = [
	  "namespace" ,
	  "environment" ,
	  "stage" ,
	  "name" ,
	  "attributes" ]
	regex_replace_chars = "/[^-a-zA-Z0-9]/"
	delimiter           = "-"
	replacement         = ""
	id_length_limit     = 0
	id_hash_length      = 5
	label_key_case      = "title"
	label_value_case    = "lower"
  }
  
  replacement    = local.default_properties.replacement
  id_hash_length = local.default_properties.id_hash_length
  
  input_metadata_options = {
	enabled     = var.enabled == null ? var.context.enabled : var.enabled
	namespace   = var.namespace == null ? var.context.namespace : var.namespace
	environment = var.environment == null ? var.context.environment : var.environment
	stage       = var.stage == null ? var.context.stage : var.stage
	name        = var.name == null ? var.context.name : var.name
	delimiter   = var.delimiter == null ? var.context.delimiter : var.delimiter
	attributes  = compact(distinct(concat(coalesce(var.context.attributes , [ ]) , coalesce(var.attributes , [ ]))))
	tags        = merge(var.context.tags , var.tags)
	
	additional_tag_map  = merge(var.context.additional_tag_map , var.additional_tag_map)
	label_order         = var.label_order == null ? var.context.label_order : var.label_order
	regex_replace_chars = var.regex_replace_chars == null ? var.context.regex_replace_chars : var.regex_replace_chars
	id_length_limit     = var.id_length_limit == null ? var.context.id_length_limit : var.id_length_limit
	label_key_case      = var.label_key_case == null ? lookup(var.context , "label_key_case" , null) : var.label_key_case
	label_value_case    = var.label_value_case == null ? lookup(var.context , "label_value_case" , null) : var.label_value_case
  }
  
  
  enabled             = local.input_metadata_options.enabled
  regex_replace_chars = coalesce(local.input_metadata_options.regex_replace_chars , local.default_properties
  .regex_replace_chars)
  
  string_label_names    = [
	"name" ,
	"namespace" ,
	"environment" ,
	"stage" ]
  normalized_labels     = { for k in local.string_label_names : k =>
  local.input_metadata_options[ k ] == null ? "" : replace(local.input_metadata_options[ k ] , local.regex_replace_chars , local.replacement)
  }
  normalized_attributes = compact(distinct([ for v in local.input_metadata_options.attributes : replace(v , local.regex_replace_chars , local.replacement) ]))
  
  formatted_labels = { for k in local.string_label_names : k => local.label_value_case == "none" ? local.normalized_labels[ k ] :
  local.label_value_case == "title" ? title(lower(local.normalized_labels[ k ])) :
  local.label_value_case == "upper" ? upper(local.normalized_labels[ k ]) : lower(local.normalized_labels[ k ])
  }
  
  attributes = compact(distinct([
  for v in local.normalized_attributes : (local.label_value_case == "none" ? v :
  local.label_value_case == "title" ? title(lower(v)) :
  local.label_value_case == "upper" ? upper(v) : lower(v))
  ]))
  
  name        = local.formatted_labels[ "name" ]
  namespace   = local.formatted_labels[ "namespace" ]
  environment = local.formatted_labels[ "environment" ]
  stage       = local.formatted_labels[ "stage" ]
  
  delimiter        = local.input_metadata_options.delimiter == null ? local.default_properties.delimiter : local.input_metadata_options.delimiter
  label_order      = local.input_metadata_options.label_order == null ? local.default_properties.label_order : coalescelist(local.input_metadata_options.label_order , local.default_properties.label_order)
  id_length_limit  = local.input_metadata_options.id_length_limit == null ? local.default_properties.id_length_limit : local.input_metadata_options.id_length_limit
  label_key_case   = local.input_metadata_options.label_key_case == null ? local.default_properties.label_key_case : local.input_metadata_options.label_key_case
  label_value_case = local.input_metadata_options.label_value_case == null ? local.default_properties.label_value_case : local.input_metadata_options.label_value_case
  
  additional_tag_map = merge(var.context.additional_tag_map , var.additional_tag_map)
  
  tags = merge(local.generated_tags , local.input_metadata_options.tags)
  
  tags_as_list_of_maps = flatten([
  for key in keys(local.tags) : merge(
  {
	key   = key
	value = local.tags[ key ]
  } , var.additional_tag_map)
  ])
  
  tags_context = {
	name        = local.id
	namespace   = local.namespace
	environment = local.environment
	stage       = local.stage
	attributes  = local.id_context.attributes
  }
  
  generated_tags = {
  for l in keys(local.tags_context) :
  local.label_key_case == "upper" ? upper(l) : (
  local.label_key_case == "lower" ? lower(l) : title(lower(l))
  ) => local.tags_context[ l ] if length(local.tags_context[ l ]) > 0
  }
  
  id_context = {
	name        = local.name
	namespace   = local.namespace
	environment = local.environment
	stage       = local.stage
	attributes  = join(local.delimiter , local.attributes)
  }
  
  labels = [ for l in local.label_order : local.id_context[ l ] if length(local.id_context[ l ]) > 0 ]
  
  id_full                   = join(local.delimiter , local.labels)
  delimiter_length          = length(local.delimiter)
  id_truncated_length_limit = local.id_length_limit - (local.id_hash_length + local.delimiter_length)
  id_truncated              = local.id_truncated_length_limit <= 0 ? "" : "${trimsuffix(substr(local.id_full, 0,
  local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  id_hash_plus              = "${md5(local.id_full)}qrstuvwxyz"
  id_hash_case              = local.label_value_case == "title" ? title(local.id_hash_plus) : local.label_value_case == "upper" ? upper(local.id_hash_plus) : local.label_value_case == "lower" ? lower(local.id_hash_plus) : local.id_hash_plus
  id_hash                   = replace(local.id_hash_case , local.regex_replace_chars , local.replacement)
  id_short                  = substr("${local.id_truncated}${local.id_hash}" , 0 , local.id_length_limit)
  id                        = local.id_length_limit != 0 && length(local.id_full) > local.id_length_limit ? local.id_short : local.id_full
  
  
  # To be exported
  generated_metadata_output = {
	enabled             = local.enabled
	name                = local.name
	namespace           = local.namespace
	environment         = local.environment
	stage               = local.stage
	delimiter           = local.delimiter
	attributes          = local.attributes
	tags                = local.tags
	additional_tag_map  = local.additional_tag_map
	label_order         = local.label_order
	regex_replace_chars = local.regex_replace_chars
	id_length_limit     = local.id_length_limit
	label_key_case      = local.label_key_case
	label_value_case    = local.label_value_case
  }
}
