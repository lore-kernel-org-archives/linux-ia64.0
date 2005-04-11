From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 11 Apr 2005 22:58:35 +0000
Subject: Re: [PATCH] make CONFIG_IA64_GENERIC=y && CONFIG_SMP=n work
Message-Id: <Pine.LNX.4.58.0504111557380.6547@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504111238.53982.jbarnes@engr.sgi.com>
In-Reply-To: <200504111238.53982.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 11 Apr 2005, Jesse Barnes wrote:

> P.S. I didn't include the fix for mmtimer.c && CONFIG_SMP=n here, Christoph
> can you fix it?
> drivers/char/mmtimer.c: In function `mmtimer_tasklet':
> drivers/char/mmtimer.c:488: error: structure has no member named `write_lock'

I thought this was already fixed by another patchset? But here it is
again:

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/drivers/char/mmtimer.c
=================================--- linux-2.6.11.orig/drivers/char/mmtimer.c	2005-04-05 20:24:40.000000000 -0700
+++ linux-2.6.11/drivers/char/mmtimer.c	2005-04-11 15:57:06.000000000 -0700
@@ -485,7 +485,7 @@ void mmtimer_tasklet(unsigned long data)
 		goto out;
 	t->it_overrun = 0;

-	if (tasklist_lock.write_lock || posix_timer_event(t, 0) != 0) {
+	if (posix_timer_event(t, 0) != 0) {

 		// printk(KERN_WARNING "mmtimer: cannot deliver signal.\n");

