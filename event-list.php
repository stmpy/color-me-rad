<?php
/**
 * Template Name: Eventbrite API: Event List
 */

// load salient page
require_once(dirname(__FILE__) . "/../salient/page.php");
?>

<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/underscore/underscore.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/backbone/backbone.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/marionette/lib/backbone.marionette.min.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/moment/moment.js"></script>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?region=US&key=AIzaSyAG2HmH0IQyQA6P2yc1oakjIfibDWr8kGM"></script>

<?php // Set up and call our Eventbrite query. ?>
<?php $events = new Eventbrite_Query( apply_filters( 'eventbrite_query_args', array(
	'display_private' => true, // boolean
	// 'limit' => null,            // integer
	// 'organizer_id' => null,     // integer
	// 'p' => null,                // integer
	// 'post__not_in' => null,     // array of integers
	// 'venue_id' => null,         // integer
))); ?>

<?php if ( $events->have_posts() ) : ?>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/app.js"></script>
	<script type="text/javascript">
	App.start(<?= json_encode($events->posts); ?>);
</script>
<?php endif; ?>
<h1><?= dirname(__FILE__) . "/../salient/page.php" ?></h1>
