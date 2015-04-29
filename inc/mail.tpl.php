<html lang="en">
	<head>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type">
		<title>Modern</title>
		<style type="text/css">
			table { border: 0; }
		</style>
	</head>
	<body>
		<table cellspacing="0" cellpadding="5px">
			<tr>
				<td>Nom</td>
				<td>{name}</td>
			</tr>
			<tr>
				<td>Email</td>
				<td><a href="mailto:{mail}">{mail}</td>
			</tr>
			<tr>
				<td>Message</td>
				<td>{message}</td>
			</tr>
		</table>
		<p><i>Email automatique envoyé le {jsmail_date} depuis l'adresse <a target="_blank" href="http://network-tools.com/default.asp?prog=express&host={jsmail_ip}">{jsmail_ip}</a></i></p>
	</body>
</html>