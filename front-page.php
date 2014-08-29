<?php
/**
 * The template for displaying the homepage.
 *
 * @package _s
 */

get_header(); ?>

<div id="primary" class="content-area">
	<main id="main" class="site-main" role="main">

		<?php while ( have_posts() ) : the_post(); ?>

			<?php get_template_part( 'content', 'page' ); ?>

		<?php endwhile; ?>

	</main>
</div>

<?php get_footer(); ?>
