From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 07 Dec 2005 19:24:42 +0000
Subject: RE: [PATCH] Fix missing parameter for local_add
Message-Id: <Pine.LNX.4.62.0512071122350.24946@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 Dec 2005, Luck, Tony wrote:

> 
> -#define local_add(l)	atomic64_add(&(l)->val)
> +#define local_add(i, l)	atomic64_add((i), &(l)->val)
>  #define local_sub(l)	atomic64_sub(&(l)->val)
>  
>  
> local_sub() looks like it could use the same treatment?

yes. So:

Index: linux-2.6.15-rc5/include/asm-ia64/local.h
=================================--- linux-2.6.15-rc5.orig/include/asm-ia64/local.h	2005-12-03 21:10:42.000000000 -0800
+++ linux-2.6.15-rc5/include/asm-ia64/local.h	2005-12-07 11:23:51.000000000 -0800
@@ -17,8 +17,8 @@ typedef struct {
 #define local_set(l, i)	atomic64_set(&(l)->val, i)
 #define local_inc(l)	atomic64_inc(&(l)->val)
 #define local_dec(l)	atomic64_dec(&(l)->val)
-#define local_add(l)	atomic64_add(&(l)->val)
-#define local_sub(l)	atomic64_sub(&(l)->val)
+#define local_add(i, l)	atomic64_add((i), &(l)->val)
+#define local_sub(i, l)	atomic64_sub((i), &(l)->val)
 
 /* Non-atomic variants, i.e., preemption disabled and won't be touched in interrupt, etc.  */
 
