<?php
/**
 * Template Name: Eventbrite API: Event List
 */

// load salient page
require_once(dirname(__FILE__) . "/../salient/page.php");
require_once(dirname(__FILE__) . "/js-libraries.php");
?>

<?php // Set up and call our Eventbrite query. ?>
<?php $events = new Eventbrite_Query( apply_filters( 'eventbrite_query_args', array(
	'display_private' => true, // boolean
	// 'limit' => null,            // integer
	// 'organizer_id' => null,     // integer
	// 'p' => null,                // integer
	// 'post__not_in' => null,     // array of integers
	// 'venue_id' => null,         // integer
))); ?>

<?php if ( is_object($events) && $events->have_posts() ) : ?>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/list-app.js"></script>
<script type="text/javascript">
	App.start(<?= json_encode($events->posts); ?>);
</script>
<?php endif; ?>
