<?php
/**
 * Template Name: Color Me Rad Eventbrite Events
 */

get_header();

nectar_page_header($post->ID); ?>

<!-- <script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/foundation/js/foundation/foundation.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/foundation/js/foundation/foundation.tab.js"></script> -->
<!-- <link type="text/css" rel="stylesheet" href="<?php bloginfo('template_url'); ?>-child/events.css" /> -->
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/underscore/underscore.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/backbone/backbone.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/marionette/lib/backbone.marionette.min.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/moment/moment.js"></script>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?region=US&key=AIzaSyAG2HmH0IQyQA6P2yc1oakjIfibDWr8kGM"></script>
	<div id="primary" class="content-area">
		<main id="main" role="main">

			<?php if(get_query_var( 'event_id', false)): ?>

				<?php $event = new Eventbrite_Query( array( 'p' => get_query_var( 'event_id' ) ) ); ?>

				<?php if ( $event->have_posts() ) : ?>
					<header style="background-color: #024481;">
						<div class="row" style="">
							<div class="large-12 columns">
								<h1 style="color: #cccccc;"><?= $event->post->post_title ?></h1>
								<h2 style="color: #cccccc;"><?= date("l, F jS Y",strtotime($event->post->start->local)) ?></h2>
								<h2 style="color: #cccccc;"><?= $event->post->venue->address->city ?></h2>
							</div>
						</div>
					</header>
					<div class="content">Error retreiving event details ...</div>
					<script type="text/javascript">
					App.start(<?= json_encode($event->post); ?>);
					</script>

				<?php else :
					// If no content, include the "No posts found" template.
					get_template_part( 'content', 'none' );

				endif;

				// Return $post to its rightful owner.
				wp_reset_postdata();
			endif; ?>

		</main><!-- #main -->
	</div><!-- #primary -->

<?php get_sidebar(); ?>
<?php get_footer(); ?>
