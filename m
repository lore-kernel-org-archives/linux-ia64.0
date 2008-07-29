From: Simon Horman <horms@verge.net.au>
Date: Tue, 29 Jul 2008 09:47:20 +0000
Subject: [patch] IA64: only call up() in salinfo_work_to_do() if
Message-Id: <20080729094718.GA5247@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>

Aesthetic issues aside is it safe to call up() if down_trylock() failed?

arch/ia64/kernel/salinfo.c: In function `salinfo_work_to_do':
arch/ia64/kernel/salinfo.c:195: warning: ignoring return value of `down_trylock'

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/kernel/salinfo.c
=================================--- linux-2.6.orig/arch/ia64/kernel/salinfo.c	2008-07-29 19:06:33.000000000 +1000
+++ linux-2.6/arch/ia64/kernel/salinfo.c	2008-07-29 19:40:02.000000000 +1000
@@ -192,8 +192,8 @@ struct salinfo_platform_oemdata_parms {
 static void
 salinfo_work_to_do(struct salinfo_data *data)
 {
-	down_trylock(&data->mutex);
-	up(&data->mutex);
+	if (down_trylock(&data->mutex) = 0)
+		up(&data->mutex);
 }
 
 static void
