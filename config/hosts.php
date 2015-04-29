<?php

	/**
	 * printr() - debug purposes
	 */
	if (!function_exists('printr'))
	{
		function printr($string) { echo '<pre>'; var_dump($string); echo '</pre>'; }
	}

	/**
	 * Hosts config managment depending on current domain
	 */
	class JSHostsManager
	{
		
		private $defaultFile;
		private $hostsPath;
		private $currentDomain;
		
		/**
		 * Constructor.
		 */
		public function __construct()
		{
			$this->defaultFile = 'default.php';
			$this->hostsPath = dirname(__FILE__);
			$this->currentDomain = $this->getCurrentDomain();
			require_once($this->getDomainFile($this->currentDomain));
		}
	
		/**
		 * Tries to get the current domain depending on the server config
		 * @return String
		 */
		private function getCurrentDomain()
		{
			$http_host = (isset($_SERVER ['HTTP_HOST']) && !empty($_SERVER ['HTTP_HOST'])) ? $_SERVER ['HTTP_HOST'] : false;
			$server_name = (isset($_SERVER ['SERVER_NAME']) && !empty($_SERVER ['SERVER_NAME'])) ? $_SERVER ['SERVER_NAME'] : false;
			if ($server_name)
				return $server_name;
			if ($http_host)
				return $http_host;
			return false;
		}
		
		/**
		 * Gets the domain file
		 * @param String	the domain
		 * @return String 	the path
		 */
		private function getDomainFile($domain)
		{
			if (!$domain)
				return $this->defaultFile;
			$dir = dirname(__FILE__) . '/';
			$path = $dir . $domain . '.php';
			$default_path = $dir . $this->defaultFile;
			return (file_exists($path)) ? $path : $default_path;
		}
	
	}
	
	new JSHostsManager();
