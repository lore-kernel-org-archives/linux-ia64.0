From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 29 Aug 2003 20:38:58 +0000
Subject: minor fix for elilo-3.4
MIME-Version: 1
Content-Type: multipart/mixed; boundary="xgyAXRrhYN0wYx8y"
Message-Id: <marc-linux-ia64-106219051513138@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--xgyAXRrhYN0wYx8y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

There was an extraneous debug print left over in elilo-3.4 as released last
week. Bill Nottingham notice it and provide the attached patch for it.

To avoid multiple reports for the same bug I have updated the elilo-3.4
package to include the fix. The version remains the same, you can 
simply download and recompile (or use the provided binaries).

The updated package is available at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.4.tar.gz
	MD5SUM: e7357929dfca29436d35ad6386fc051c

Sorry for the inconvenience.

-- 

-Stephane

--xgyAXRrhYN0wYx8y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-3.4-debug.patch"

--- elilo-3.4/elilo.c.foo	2003-08-22 11:36:36.000000000 -0400
+++ elilo-3.4/elilo.c	2003-08-22 11:37:12.000000000 -0400
@@ -564,7 +564,6 @@
 	 * parse config file (verbose becomes visible if set)
 	 */
 	ret = read_config(ptr, retry);
-	Print(L"read_config=%r\n", ret);
 	/*
 	 * when the config file is not found, we fail only if:
 	 * 	- the user did not specified interactive mode

--xgyAXRrhYN0wYx8y--
