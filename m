From: Andrew Morton <akpm@osdl.org>
Date: Wed, 09 Jun 2004 07:10:36 +0000
Subject: Re: [lhcs-devel] Re: [RFC] don't create cpu/online sysfs file
Message-Id: <20040609001036.7fae44fb.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1086390257.24915.132.camel@nighthawk>
In-Reply-To: <1086390257.24915.132.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj <ashok.raj@intel.com> wrote:
>
> On Mon, Jun 07, 2004 at 09:41:49AM -0700, Dave Hansen wrote:
>  > On Mon, 2004-06-07 at 07:08, Ashok Raj wrote:plugging.
>  > > +		if (systemcfg->platform = PLATFORM_PSERIES_LPAR)
>  > > +			cpu->no_control=1;
>  > 
>  > That condition is also inverted.  Should read:
>  > 
>  > if (systemcfg->platform != PLATFORM_PSERIES_LPAR)
>  > 	cpu->no_control = 1;
> 
>  Good catch...I knew i mentioned untested :-)
> 
>  fixed patch attached...
> 
> ...
>  --- linux-2.6.7-rc2/arch/ppc64/kernel/sysfs.c~cpu_control_file	2004-06-06 13:12:06.467033408 -0700
>  +++ linux-2.6.7-rc2-root/arch/ppc64/kernel/sysfs.c	2004-06-07 10:12:45.999901454 -0700
>  @@ -325,6 +325,16 @@ static int __init topology_init(void)
>   #ifdef CONFIG_NUMA
>   		parent = &node_devices[cpu_to_node(cpu)];
>   #endif
>  +		/*
>  +		 * For now, we just see if the system supports making
>  +		 * the RTAS calls for CPU hotplug.  But, there may be a
>  +		 * more comprehensive way to do this for an individual
>  +		 * CPU.  For instance, the boot cpu might never be valid
>  +		 * for hotplugging.
>  +		 */
>  +		if (systemcfg->platform != PLATFORM_PSERIES_LPAR)
>  +			cpu->no_control=1;
>  +
>   		register_cpu(c, cpu, parent);
>   
>   		register_cpu_pmc(&c->sysdev);
> 

The ppc64 part doesn't compile - `cpu' is an integer.
