<?php

add_action( 'wp_enqueue_scripts', 'enqueue_parent_theme_style' );
function enqueue_parent_theme_style() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri().'/style.css' );
}

function add_query_vars($aVars) {
	$aVars[] = 'event_id';
	return $aVars;
}
add_filter('query_vars','add_query_vars');

// function add_rewrite_rules($aRules) {
// 	$aewRules = array('eventbrite_id')
// }