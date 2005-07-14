From: Ashok Raj <ashok.raj@intel.com>
Date: Thu, 14 Jul 2005 16:02:07 +0000
Subject: Re: Fix undefined reference to can_cpei_retarget for simulator build
Message-Id: <20050714090206.A1155@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050714040909.GB15249@cse.unsw.EDU.AU>
In-Reply-To: <20050714040909.GB15249@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 14, 2005 at 02:09:10PM +1000, Ian Wienand wrote:
> Hi,
> 
> The change @ http://tinyurl.com/dsxf4 broke the simulator build
> (http://www.gelato.unsw.edu.au/kerncomp).
> 
> The simulator build doesn't turn on ACPI, so doesn't have a definition
> of can_cpei_retarget.  Suggested patch attached.

Sorry about that, never compiled for the simulator yet.

You might want to send this with the Signed-off-by signature as specified
in Documentation/SubmittingPatches.

thanks for fixing this.

Cheers,
ashok

> 
> Thanks,
> 
> -i
> ianw@gelato.unsw.edu.au
> http://www.gelato.unsw.edu.au

> diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
> --- a/arch/ia64/kernel/topology.c
> +++ b/arch/ia64/kernel/topology.c
> @@ -36,12 +36,14 @@ int arch_register_cpu(int num)
>  	parent = &sysfs_nodes[cpu_to_node(num)];
>  #endif /* CONFIG_NUMA */
>  
> +#ifdef CONFIG_ACPI_BOOT
>  	/*
>  	 * If CPEI cannot be re-targetted, and this is
>  	 * CPEI target, then dont create the control file
>  	 */
>  	if (!can_cpei_retarget() && is_cpu_cpei_target(num))
>  		sysfs_cpus[num].cpu.no_control = 1;
> +#endif
>  
>  	return register_cpu(&sysfs_cpus[num].cpu, num, parent);
>  }




-- 
Cheers,
Ashok Raj
- Open Source Technology Center
