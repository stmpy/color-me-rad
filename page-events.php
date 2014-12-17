<?php get_header(); ?>

<?php nectar_page_header($post->ID); ?>

<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/underscore/underscore.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/backbone/backbone.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/marionette/lib/backbone.marionette.min.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/moment/moment.js"></script>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?region=US&key=AIzaSyAG2HmH0IQyQA6P2yc1oakjIfibDWr8kGM"></script>
<div class="container-wrap">
	<div class="container main-content">
		<div class="row">
			<?php 
			 //buddypress
			 global $bp; 
			 if($bp && !bp_is_blog_page()) echo '<h1>' . get_the_title() . '</h1>'; ?>
			
			<?php if(have_posts()) : while(have_posts()) : the_post(); ?>
				
				<?php the_content(); ?>
	
			<?php endwhile; endif; ?>
		</div>
	</div>
</div>
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
<?php get_footer(); ?>
