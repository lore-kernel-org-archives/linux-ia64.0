From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 Apr 2006 23:54:36 +0000
Subject: Re: [PATCH] - Pass OS logical cpu number to the SN prom (bios)
Message-Id: <15771.1146182076@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060427220857.GA14901@sgi.com>
In-Reply-To: <20060427220857.GA14901@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner (on Thu, 27 Apr 2006 17:08:58 -0500) wrote:
>Pass the OS logical cpu number to the PROM. This allows PROM to 
>log the OS logical cpu number in error records viewed thru POD.
>This signifinantly simplifies diagnosis of hardware errors on 
>large systems.
>
>	Signed-off-by: Jack Steiner <steiner@sgi.com>
>
>
>
>Index: linux/arch/ia64/sn/kernel/setup.c
>=================================>--- linux.orig/arch/ia64/sn/kernel/setup.c	2006-04-22 08:50:14.567000831 -0500
>+++ linux/arch/ia64/sn/kernel/setup.c	2006-04-27 17:02:24.646672915 -0500
>@@ -597,6 +597,12 @@ void __init sn_cpu_init(void)
> 	sn_hub_info->as_shift = sn_hub_info->nasid_shift - 2;
> 
> 	/*
>+	 * Don't check status. The SAL call is not supported on all PROMs
>+	 * but a failure is harmless.
>+	 */
>+	(void) ia64_sn_set_cpu_number(smp_processor_id());
>+
>+	/*
> 	 * The boot cpu makes this call again after platform initialization is
> 	 * complete.
> 	 */

Nit pick.  sn_cpu_init() defines a cpuid variable which is set to
smp_processor_id(), but smp_processor_id() is used once (twice with
this patch) before cpuid is defined and used.  Move the definition of
cpuid to the top of the function and use it throughout.

