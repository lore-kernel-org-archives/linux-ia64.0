From: Russ Anderson <rja@sgi.com>
Date: Mon, 17 Jan 2005 22:01:37 +0000
Subject: Re: [patch] Remove limit on MCA recoveries
Message-Id: <200501172201.j0HM1bEo3012537@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
In-Reply-To: <200501152249.j0FMn6JH2857539@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> Agreed.  If you want to increase the static limit up from 32 to a thousand
> or so, as an interim fix until such extra page_flags are agreed upon, then
> I'll be ok with that.

Sounds good.  Thanks, Tony.  Here is a patch.

Of course very quickly _only_ 1024 recoveries won't be enough.  :-)

Signed-off-by: Russ Anderson <rja@sgi.com>

----------------------------------------------------------------------------
Index: 2.6.11/arch/ia64/kernel/mca_drv.c
=================================--- 2.6.11.orig/arch/ia64/kernel/mca_drv.c	2005-01-17 15:55:26.280000969 -0600
+++ 2.6.11/arch/ia64/kernel/mca_drv.c	2005-01-17 15:55:56.151772456 -0600
@@ -52,7 +52,7 @@
 	MCA_IS_GLOBAL = 1
 } mca_type_t;
 
-#define MAX_PAGE_ISOLATE 32
+#define MAX_PAGE_ISOLATE 1024
 
 static struct page *page_isolate[MAX_PAGE_ISOLATE];
 static int num_page_isolate = 0;

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
