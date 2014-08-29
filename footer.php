<?php
/**
 * The template for displaying the footer.
 *
 * Contains the closing of the #content div and all content after
 *
 * @package _s
 */
?>

	</div><?php // .site__content ?>

	<footer class="site__footer" role="contentinfo">
		<div class="container">
			<p><small>Copyright &copy; <?php echo date('Y'); ?> <?php bloginfo('title'); ?></small></p>
		</div>
	</footer>

</div>

<?php wp_footer(); ?>

</body>
</html>
