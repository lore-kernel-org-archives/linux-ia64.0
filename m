From: Nathan Lynch <nathanl@austin.ibm.com>
Date: Mon, 07 Jun 2004 14:07:38 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <40C476AA.7070403@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave Hansen wrote:
> diff -urp linux-2.6.7-rc2-mm2-clean/drivers/base/cpu.c linux-2.6.7-rc2-mm2-cpuonline2/drivers/base/cpu.c
> --- linux-2.6.7-rc2-mm2-clean/drivers/base/cpu.c	Fri Jun  4 13:27:09 2004
> +++ linux-2.6.7-rc2-mm2-cpuonline2/drivers/base/cpu.c	Sun Jun  6 21:59:35 2004
> @@ -75,7 +75,7 @@ int __init register_cpu(struct cpu *cpu,
>  		error = sysfs_create_link(&root->sysdev.kobj,
>  					  &cpu->sysdev.kobj,
>  					  kobject_name(&cpu->sysdev.kobj));
> -	if (!error)
> +	if (!error && !cpu->can_control)

Should be:
+	if (!error && cpu->can_control)

Right?


> diff -urp linux-2.6.7-rc2-mm2-clean/include/linux/cpu.h linux-2.6.7-rc2-mm2-cpuonline2/include/linux/cpu.h
> --- linux-2.6.7-rc2-mm2-clean/include/linux/cpu.h	Fri Jun  4 13:27:11 2004
> +++ linux-2.6.7-rc2-mm2-cpuonline2/include/linux/cpu.h	Sun Jun  6 21:58:35 2004
> @@ -27,6 +27,7 @@
>  
>  struct cpu {
>  	int node_id;		/* The node which contains the CPU */
> +	int can_control;	/* Should the sysfs control file be created? */

Minor nit -- could we change this comment to "Could this cpu ever be 
hotpluggable?"  Or just name the field "hotpluggable"?  That would 
better document the intent here, wouldn't it?


Nathan
