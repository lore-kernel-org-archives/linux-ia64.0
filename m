From: Chris Wedgwood <cw@f00f.org>
Date: Thu, 10 Mar 2005 18:18:35 +0000
Subject: [PATCH] silence sort(..., swap) warning on ia64
Message-Id: <20050310181835.GA8348@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Cc: Matt Mackall <mpm@selenic.com>

Not tested but seems plausible :-)

=== arch/ia64/mm/extable.c 1.11 vs edited ==--- 1.11/arch/ia64/mm/extable.c	2005-03-07 20:41:46 -08:00
+++ edited/arch/ia64/mm/extable.c	2005-03-10 10:14:55 -08:00
@@ -20,7 +20,7 @@ static int cmp_ex(const void *a, const v
 	return lip - rip;
 }
 
-static void swap_ex(void *a, void *b)
+static void swap_ex(void *a, void *b, int _unused_size)
 {
 	struct exception_table_entry *l = a, *r = b, tmp;
 	u64 delta = (u64) r - (u64) l;
