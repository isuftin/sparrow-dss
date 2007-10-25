<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
    <title>ID By Point Test</title>
  </head>
  <body>
		
		<p>
			Requests the 7 closest reaches to lat/long 40/-100 in model 22<br>
			<a href="sp_idpoint/22&#63;lat=40&amp;long=-100&amp;result-count=7">sp_idpoint/22&#63;lat=40&amp;long=-100&amp;result-count=7</a>
		</p>
		
		<p>
			Same as above, but there is an internal limit to 100 reaches, so the 200 will be ignored<br>
			<a href="sp_idpoint/22&#63;lat=40&amp;long=-100&amp;result-count=200">sp_idpoint/22&#63;lat=40&amp;long=-100&amp;result-count=200</a>
		</p>
		
		<p>
			The Search for nearest reaches is only performed in a 4 deg. by 4 deg. box
			around the point, so a request like this will probably return zero points.<br>
			<a href="sp_idpoint/22&#63;lat=4&amp;long=-4&amp;result-count=7">sp_idpoint/22&#63;lat=4&amp;long=-4&amp;result-count=7</a>
		</p>
		
	</body>
</html>