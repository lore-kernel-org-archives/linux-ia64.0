From: Bill Nottingham <notting@redhat.com>
Date: Thu, 12 Jul 2001 13:54:12 +0000
Subject: [Linux-ia64] Re: gnu-efi-3.0/elilo-3.0 packages available
MIME-Version: 1
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Message-Id: <marc-linux-ia64-105590693005847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Richard Hirst (rhirst@linuxcare.com) said: 
>   I'm working on the debian installer for ia64, and have just picked
> up elilo-3.0.  I'm trying to use it interactively, with an elilo.conf.
> At the fsX: prompt I type 'elilo' and hit return.  It shows me the device
> names and a prompt, but any key I press just drops me back to an fsX:
> prompt.  Is this a known problem, or is it more likely a local
> problem with my config or elilo build?

The attached should work; it does for me.

Bill

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-timeout.patch"

diff -ru elilo-3.0-old/choosers/simple.c elilo-3.0/choosers/simple.c
--- elilo-3.0-old/choosers/simple.c	Mon Jul  2 02:00:46 2001
+++ elilo-3.0/choosers/simple.c	Mon Jul  9 23:32:04 2001
@@ -73,8 +73,8 @@
 	/*
 	 * autoboot with default choice after timeout expires
 	 */
-	if (first_time && (ret=wait_timeout(elilo_opt.timeout)) != 1) {
-		return ret == -1 ? -1: 0;
+	if (first_time && (ret=wait_timeout(elilo_opt.timeout)) == 0) {
+		return 0;
 	}
 
 	for (;;) {

--YZ5djTAD1cGYuMQK--

