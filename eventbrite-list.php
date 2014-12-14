<?php
/**
 * Template Name: Color Me Rad Eventbrite Events
 */

get_header(); ?>
<!-- <script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/foundation/js/foundation/foundation.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/foundation/js/foundation/foundation.tab.js"></script> -->
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/underscore/underscore.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/backbone/backbone.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/marionette/lib/backbone.marionette.min.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/bower_components/moment/moment.js"></script>
<script type="text/javascript" src="<?php bloginfo('template_url'); ?>-child/app.js"></script>
	<div id="primary" class="content-area">
		<main id="main" role="main">
			<div class="row">
				<header class="page-header">
					<h1 class="page-title">
						<?php the_title(); ?>
					</h1>
				</header><!-- .page-header -->

				<dl class="tabs" data-tab>PUT TABS HERE</dl>

				<div class="content">PUT CONTENT HERE</div>

				<?php
					// Set up and call our Eventbrite query.
					$events = new Eventbrite_Query( apply_filters( 'eventbrite_query_args', array(
						'display_private' => true, // boolean
						// 'limit' => null,            // integer
						// 'organizer_id' => null,     // integer
						// 'p' => null,                // integer
						// 'post__not_in' => null,     // array of integers
						// 'venue_id' => null,         // integer
					) ) );

					if ( $events->have_posts() ) : ?>
					<script type="text/javascript">

					App.start(<?= json_encode($events->posts); ?>);
					</script>

					<?php else :
						// If no content, include the "No posts found" template.
						get_template_part( 'content', 'none' );

					endif;

					// Return $post to its rightful owner.
					wp_reset_postdata();
				?>

			</div>
			<div style="clear:both"></div>
		</main><!-- #main -->
	</div><!-- #primary -->

<?php get_sidebar(); ?>
<?php get_footer(); ?>
