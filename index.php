<?php
	require_once('./config/hosts.php');
	require_once('./inc/contact.php');
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
	<meta http-equiv="content-language" content="en,fr" />	
	<title>Johan Satgé • Développeur web &amp; Technical Artist</title>
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	<meta name="robots" content="index, follow" />
	<link rel="shortcut icon" type="image/x-icon" href="./img/favicon.png" />
	<link rel="stylesheet" href="./css/noflash.css" type="text/css" media="screen" />
	<script type="text/javascript" src="./jst/swfobject.js"></script>
	<script type="text/javascript" src="./jst/swfaddress.js"></script>
	<script type="text/javascript">
		var flashvars  = {siteURL:"<?php echo SITE_URL?>"};
		var attributes = {};
		var params     = {allowFullScreen : true , AllowScriptAccess : 'sameDomain'};
		document.write('<link rel="stylesheet" href="./css/flash.css" type="text/css" media="screen" />');
		swfobject.embedSWF("./swf/main.swf", "main", "100%", "100%", "8", "#ffffff", flashvars, params, attributes);
	</script>
	<?php if (defined('ANALYTICS_CODE') && ANALYTICS_CODE != '') { ?>
		<script type="text/javascript">
		  var _gaq = _gaq || [];
		  _gaq.push(['_setAccount', '<?php echo ANALYTICS_CODE?>']);
		  _gaq.push(['_trackPageview']);
		  (function() {
		    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
		    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
		    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		  })();
		</script>
	<?php } ?>
</head>
	<body>		
		<div id="main">
			<?php $config = simplexml_load_string(file_get_contents('./xml/config.xml')); ?>
			<h1><?php echo $config->main_menu->title?></h1>
			<h2><?php echo $config->main_menu->subtitle?></h2>
			<?php foreach($config->pages->page as $page) { ?>
				<?php
					if ($page->attributes()->id != 'contact')
					{
						foreach($page->section as $section)
						{
							?>
								<h3><?php echo $section->title?></h3>
								<p><?php echo $section->front?></p>
								<p><?php echo $section->back?></p>
							<?php
						}
					}
					else
					{
						?>
							<h3><?php echo $page->title?></h3>
							<?php
								foreach($page->labels->label as $label)
								{
									if ($label->attributes()->object == 'introLabel' || $label->attributes()->object == 'infosLabel')
									{
										?>
											<p><?php echo $label?></p>
										<?php
									}
								}
							?>
						<?php
					}
				?>
			<?php } ?>
			<ul>
				<?php foreach($config->main_menu->items->item as $item) { ?>
					<?php foreach($item->link as $link) { ?>
						<li><a href="<?php echo $link->attributes()->url?>"><?php echo $link->attributes()->label?></a></li>
					<?php } ?>
				<?php } ?>
			</ul>
		</div>
	</body>
</html>

<?php
	// Récupération des news
	/*$news_xml = simplexml_load_string(file_get_contents(url_site . '/xml/news.php'));
	foreach($news_xml->news as $news)
	{
		?>
			<tr>
				<td valign="top">
					<a href="<?php echo $news->link->attributes()->url?>">
						<img src="<?php echo $news->photo->attributes()->path?>" width="200px" alt="<?php echo cleanAlt(stripslashes($news->titre))?>" />
					</a>
				</td>
				<td width="10px"></td>
				<td width="600px" valign="top">
					<h3><?php echo stripslashes($news->titre)?></h3>
					<p><?php echo stripslashes($news->description)?></p>
				</td>
			</tr>
			<tr><td colspan="2" height="10px"></td></tr>
		<?php
	}*/
?>