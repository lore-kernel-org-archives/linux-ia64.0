From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 24 Jul 2001 00:25:02 +0000
Subject: [Linux-ia64] elilo-3.0 minor fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="GRPZ8SYKNexpdSJ7"
Message-Id: <marc-linux-ia64-105590693005883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The attached patch fixes the problem reported by Richard Hirst with regards
to typing return with no text at the elilo boot prompt. This patch only
applies to elilo-3.0


-- 
-Stephane

--GRPZ8SYKNexpdSJ7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="elilo-010723.diff"

--- elilo-3.0/util.c	Mon Jul  2 00:57:29 2001
+++ elilo-3.1/util.c	Mon Jul 23 16:01:34 2001
@@ -135,7 +135,7 @@
 
 	BS->CloseEvent(timer);
 
-	return idx ? -1 : 0;
+	return idx ? 1 : 0;
 }
 
 INTN

--GRPZ8SYKNexpdSJ7--

