From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 03:23:59 +0000
Subject: RE:  ia64 get_mmu_context patch
Message-Id: <200510280323.j9S3Nxg12628@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Keilty wrote on Thursday, October 27, 2005 10:28 AM
> Please find attached IA64 context_id patch and supporting data for your
> Review and consideration.
> 
> --- linux-2.6.14-rc3/arch/ia64/kernel/setup.c	2005-10-26 10:54:06.000000000 -0400
> +++ linux-2.6.14-rc3pmk/arch/ia64/kernel/setup.c	2005-10-25 14:53:59.000000000 -0400
> @@ -419,6 +419,7 @@
> ...
>  
>  	/* set ia64_ctx.max_rid to the maximum RID that is supported by all CPUs: */
> -	if (ia64_pal_vm_summary(NULL, &vmi) = 0)
> +	if (ia64_pal_vm_summary(NULL, &vmi) = 0) {
>  		max_ctx = (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
> -	else {
> +		if (max_ctx > (1U << 21)) {
> +			max_ctx = (1U << 21) - 1;	/* limit to 2^21  */
> +			printk(KERN_WARNING "cpu_init: max_ctx limited to 21 RID bits for bitmap size\n");
> +		}
> +	} else {

This printk is spurious.  When I first read it, my reaction is: rid as
in region register is architecturally defined at maximum 24 bits.  Printing 
21-bit for rid is misleading.  We currently use 8 rid number per process.
So 21 bit for context number is the max.  max_ctx will never exceed 1<<21.
Suggest this printk to be dropped.

- Ken

