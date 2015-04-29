<?php

	if (isset($_GET ['contact']))
	{
		require_once(dirname(__FILE__) . '/jsmail.class.php');
		$mailer = new JSMail('Nouveau message depuis ' . SITE_DOMAIN , dirname(__FILE__) . '/mail.tpl.php');
		$mailer->setDateFormat('d/m/Y à H:i:s');
		$mailer->registerField('name' , array('required'));
		$mailer->registerField('mail');
		$mailer->registerField('message' , array('required'));
		$mailer->registerReceipts('contact@johansatge.fr');
		echo $mailer->send();
		exit;
	}