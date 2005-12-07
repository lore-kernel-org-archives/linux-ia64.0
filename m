From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 07 Dec 2005 19:36:45 +0000
Subject: Re: [PATCH] Fix missing parameter for local_add
Message-Id: <Pine.LNX.4.62.0512071136090.25009@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512071053450.24789@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 7 Dec 2005, Bjorn Helgaas wrote:

> On Wednesday 07 December 2005 11:54 am, Christoph Lameter wrote:
> > Local add needs to have a parameter that specifies how much to add
> > to a local_t. atomic64_add also requires two parameters.
> 
> AOL: what about local_sub()?

Tony alrady noticed and I send him this fixed up patch:

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
 
