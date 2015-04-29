<?php

	/**
	 * Mail class
	 */
	class JSMail
	{
		
		// Errors
		const NO_FIELDS_FOUND = 'NO_FIELDS_FOUND';
		const REQUIRED_FIELD_MISSING = 'REQUIRED_FIELD_MISSING';
		const MAIL_ERROR = 'MAIL_ERROR';
		const MAIL_OK = 'MAIL_OK';
		
		// Internal vars
		private $template;
		private $fields;
		private $receipts;
		private $subject;
		private $dateFormat;
		
		/**
		 * Constructor.
		 * @param String	$subject	the subject
		 * @param String	$template	the template
		 */
		public function __construct($subject , $template)
		{
			$this->template = $template;
			$this->fields = array();
			$this->receipts = array();
			$this->subject = $subject;
			$this->dateFormat = 'Y/m/d';
		}
		
		/**
		 * Sets the date format
		 */
		public function setDateFormat($format)
		{
			$this->dateFormat = $format;
		}
		
		/**
		 * Registers a field
		 * @param String	$name			the field name
		 * @param Array		$attributes		the field options (contains the options: 'required' , 'numeric' , 'email', etc)
		 */
		public function registerField($name , $attributes = array())
		{
			$this->fields [$name] = $attributes;
		}
		
		/**
		 * Registers one or several receipts
		 * @param String|Array		$receipts	the receipt (one as a string, or a list (array)
		 */
		public function registerReceipts($receipts)
		{
			if (is_array($receipts))
				$this->receipts = array_merge($this->receipts , $receipts);
			else
				array_push($this->receipts , $receipts);
		}
		
		/**
		 * Sends the mail
		 */
		public function send()
		{
			$headers = $this->makeHeaders();
			$fields = $this->checkFields();
			if (!is_array($fields))
				return $fields;
			$fields = $this->addSystemFields($fields);
			$template = $this->fillTemplateWith($fields);
			$result = true;
			foreach($this->receipts as $receipt)
			{
				$sent = mail($receipt , $this->subject , $template , $headers);
				if (!$sent)
					$result = false;
			}
			return ($result) ? self::MAIL_OK : self::MAIL_ERROR;
		}
		
		/**
		 * Checks the fields
		 */
		private function checkFields()
		{
			if (!is_array($this->fields) || count($this->fields) < 1)
				return self::NO_FIELDS_FOUND;
			$checkedFields = array();
			foreach($this->fields as $name => $attr)
			{
				if (in_array('required' , $attr) && (!isset($_REQUEST [$name]) || empty($_REQUEST [$name])))
					return self::REQUIRED_FIELD_MISSING;
				$checkedFields [$name] = $_REQUEST [$name];
			}
			return $checkedFields;
		}
		
		/**
		 * Adds some system fields to fill the template with
		 * @param Array	$fields	the user fields
		 */
		private function addSystemFields($fields)
		{
			$fields ['jsmail_ip'] = isset($_SERVER ['REMOTE_ADDR']) ? $_SERVER ['REMOTE_ADDR'] : '0.0.0.0';
			$fields ['jsmail_date'] = date($this->dateFormat);
			return $fields;
		}
		
		/**
		 * Makes the headers
		 */
		private function makeHeaders()
		{
			$headers_data = array();
			$headers_data [] = 'From: TODO GET NOM <TODO GET EMAIL>';
			$headers_data [] = 'X-Mailer: PHP/' . phpversion();
			$headers_data [] = 'MIME-Version: 1.0';
			$headers_data [] = 'Content-Type: text/html; charset=utf-8';
			$headers_data [] = 'Content-Transfer-Encoding: 8bit';
			$headers = '';
			foreach($headers_data as $value)
				$headers .= $value . "\r\n";
			return $headers;
		}
		
		/**
		 * Fills the template file with the data
		 * @param Array	$fields	the fields list (associative array)
		 */
		private function fillTemplateWith($fields)
		{
			ob_start();
		    include($this->template);
		    $template = ob_get_contents();
		    ob_end_clean();
			foreach($fields as $key => $value)
				$template = str_replace('{' . $key .'}' , $value , $template);
			return $template;
		}
		
	}
