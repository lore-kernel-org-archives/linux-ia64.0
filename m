From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 14 Jun 2002 00:01:02 +0000
Subject: [Linux-ia64] Minor patch to ppp_generic.c
Message-Id: <marc-linux-ia64-105590701905674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To compile ppp_generic.c, you need to attached patch, because the IA64
headers #define outl to be something that doesn't look like a label.

The `real' fix is probably to fix the outl definitions to avoid using
up namespace.


--- /tmp/geta376	Fri Jun 14 09:57:19 2002
+++ linux-2.5.18-patched/drivers/net/ppp_generic.c	Fri Jun 14 09:54:49 2002
@@ -2437,7 +2437,7 @@
 	write_lock_bh(&pch->upl);
 	ret = -EINVAL;
 	if (pch->ppp != 0)
-		goto outl;
+		goto out1;
 
 	ppp_lock(ppp);
 	if (pch->file.hdrlen > ppp->file.hdrlen)
@@ -2452,7 +2452,7 @@
 	ppp_unlock(ppp);
 	ret = 0;
 
- outl:
+ out1:
 	write_unlock_bh(&pch->upl);
  out:
 	up(&all_ppp_sem);

