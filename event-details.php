<?php
/**
 * Template Name: Eventbrite API: Event Details
 */

// load salient page
require_once(dirname(__FILE__) . "/../salient/page.php");
require_once(dirname(__FILE__) . "/js-libraries.php");
?>

<?php $event = new Eventbrite_Query( array( 'p' => get_query_var( 'event_id' ) ) ); ?>
<?php // var_dump($event); ?>
<?php if ( $event->have_posts() ) : ?>
<link rel="stylesheet" href="<?php bloginfo('template_url'); ?>-child/icomoon/style.css">
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/details-app.js"></script>
<script type="text/javascript">
	App.start(<?= json_encode($event->post); ?>);
</script>

<?php endif; ?>
