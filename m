From: Dean Nelson <dcn@sgi.com>
Date: Wed, 13 Jul 2005 12:44:52 +0000
Subject: Re: [PATCH] fix call of smp_processor_id() by XPC while preemptible
Message-Id: <20050713124452.GA4798@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
In-Reply-To: <42D41A65.mailx8QB11670O@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 12, 2005 at 09:47:54PM +0100, Christoph Hellwig wrote:
> On Tue, Jul 12, 2005 at 02:30:45PM -0500, Dean Nelson wrote:
> >  	xpc_vars_part[partid].IPI_amo_pa = __pa(part->local_IPI_amo_va);
> > -	xpc_vars_part[partid].IPI_nasid = cpuid_to_nasid(smp_processor_id());
> > -	xpc_vars_part[partid].IPI_phys_cpuid > > -					cpu_physical_id(smp_processor_id());
> > +
> > +	preempt_disable();
> > +	cpuid = smp_processor_id();
> > +	preempt_enable();
>
> just use __smp_processor_id() (or the fashionable name of the day)
> for it.

Tony, the revised patch follows.

Christoph, I assume this is what you meant.

Thanks,
Dean



XPC calls smp_processor_id() twice from xpc_setup_infrastructure() with
preemption enabled, which gets flagged if 'DEBUG_PREEMPT=y'. This patch
replaces the two calls to smp_processor_id() by a single call to
raw_smp_processor_id() since any CPU within the partition will do.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/xpc_channel.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/xpc_channel.c	2005-07-12 12:09:14.026288661 -0500
+++ linux-2.6/arch/ia64/sn/kernel/xpc_channel.c	2005-07-13 06:48:14.408494167 -0500
@@ -72,7 +72,7 @@
 enum xpc_retval
 xpc_setup_infrastructure(struct xpc_partition *part)
 {
-	int ret;
+	int ret, cpuid;
 	struct timer_list *timer;
 	partid_t partid = XPC_PARTID(part);
 
@@ -223,9 +223,9 @@
 	xpc_vars_part[partid].openclose_args_pa  					__pa(part->local_openclose_args);
 	xpc_vars_part[partid].IPI_amo_pa = __pa(part->local_IPI_amo_va);
-	xpc_vars_part[partid].IPI_nasid = cpuid_to_nasid(smp_processor_id());
-	xpc_vars_part[partid].IPI_phys_cpuid -					cpu_physical_id(smp_processor_id());
+	cpuid = raw_smp_processor_id();	/* any CPU in this partition will do */
+	xpc_vars_part[partid].IPI_nasid = cpuid_to_nasid(cpuid);
+	xpc_vars_part[partid].IPI_phys_cpuid = cpu_physical_id(cpuid);
 	xpc_vars_part[partid].nchannels = part->nchannels;
 	xpc_vars_part[partid].magic = XPC_VP_MAGIC1;
 
