From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Mar 2006 18:00:34 +0000
Subject: Re: [PATCH: 017/017]Memory hotplug for new nodes
Message-Id: <1142618434.10906.99.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060317163911.C659.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060317163911.C659.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2006-03-17 at 17:23 +0900, Yasunori Goto wrote:
> +++ pgdat8/arch/ia64/kernel/topology.c	2006-03-16 16:06:27.000000000 +0900
> @@ -65,6 +65,21 @@ EXPORT_SYMBOL(arch_register_cpu);
>  EXPORT_SYMBOL(arch_unregister_cpu);
>  #endif /*CONFIG_HOTPLUG_CPU*/
>  
> +#ifdef CONFIG_NUMA
> +int arch_register_node(int num)
> +{
> +	if (sysfs_nodes[num].sysdev.id = num)
> +		return 0;
> +
> +	return register_node(&sysfs_nodes[num], num, 0);
> +}
> +
> +void arch_unregister_node(int num)
> +{
> +	unregister_node(&sysfs_nodes[num]);
> +	sysfs_nodes[num].sysdev.id = -1;
> +}
> +#endif

I don't have a real problem with you cluttering up ia64 code, but if
these are useful, why don't we put them in generic code?  They seem
quite arch-independent to me.

-- Dave

