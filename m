From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Wed, 22 Sep 2004 17:10:30 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[4/6]-Dynamic cpu register/unregister support
Message-Id: <20040922101029.B2631@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <20040920094106.F14208@unix-os.sc.intel.com> <20040922173400.4e717946.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040922173400.4e717946.tokunaga.keiich@jp.fujitsu.com>; from tokunaga.keiich@jp.fujitsu.com on Wed, Sep 22, 2004 at 05:34:00PM +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, len.brown@intel.com, acpi-devel@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 22, 2004 at 05:34:00PM +0900, Keiichiro Tokunaga wrote:
> On Mon, 20 Sep 2004 09:41:07 -0700 Keshavamurthy Anil S wrote:
> > ---
> > Name:topology.patch
> > Status:Tested on 2.6.9-rc2
> > Signed-off-by: Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
> > Depends:	
> > Version: applies on 2.6.9-rc2	
> > Description:
> > Extends support for dynamic registration and unregistration of the cpu,
> > by implementing and exporting arch_register_cpu()/arch_unregister_cpu().
> > Also combines multiple implementation of topology_init() functions to
> > single topology_init() in case of ia64 architecture.
> > ---
> 
> > +void arch_unregister_cpu(int num)
> > +{
> > +	struct node *parent = NULL;
> > +
> > +#ifdef CONFIG_NUMA
> > +	int node = cpu_to_node(num);
> > +	if (node_online(node))
> > +		parent = &sysfs_nodes[node];
> > +#endif /* CONFIG_NUMA */
> > +
> > +	return unregister_cpu(&sysfs_cpus[num].cpu, parent);
> > +}
> 
> I don't think that the check 'if (node_online(node))' is necessary
> because sysfs_nodes[node] is there no matter if the node is online
> or offline.  sysfs_nodes[] is cleared only when unregister_node()
> is called and it would be always called after unregister_cpu().

Yes, I agree with you. I will remove the check, or simply apply your patch:)
thanks,
Anil
