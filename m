From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 20 Jan 2004 01:47:08 +0000
Subject: Re: [PATCH] fix cast in irq_lsapic.c
Message-Id: <20040120014708.GB25523@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040116201522.GA15454@sgi.com>
In-Reply-To: <20040116201522.GA15454@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Jan 17, 2004 at 05:06:47PM +0000, Christoph Hellwig wrote:
> On Fri, Jan 16, 2004 at 12:15:22PM -0800, Jesse Barnes wrote:
> > Now that I've disabled dependency violation checking in my build of
> > binutils, I can see real warnings much more easily.
> > 
> > This patch just updates the cast in irq_lsapic.c to use the cpumask_t
> > type for the noop cast assignment to smp_affinity.
> 
> I think Jack already sent a patch for this when we were in freeze and
> the same comment applies here:  I think the method is optional, so you
> can probably just remove it, if not please add a properly prototyped
> stub function for it.

Oh yeah, forgot about that message.  Here's an updated patch.

Thanks,
Jesse

=== arch/ia64/kernel/irq_lsapic.c 1.3 vs edited ==--- 1.3/arch/ia64/kernel/irq_lsapic.c	Fri Jul 19 07:02:26 2002
+++ edited/arch/ia64/kernel/irq_lsapic.c	Mon Jan 19 17:45:48 2004
@@ -34,5 +34,4 @@
 	.disable =	lsapic_noop,
 	.ack =		lsapic_noop,
 	.end =		lsapic_noop,
-	.set_affinity =	(void (*)(unsigned int, unsigned long)) lsapic_noop
 };
