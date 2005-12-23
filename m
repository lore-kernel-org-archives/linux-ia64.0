From: Greg KH <greg@kroah.com>
Date: Fri, 23 Dec 2005 19:16:10 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <20051223191610.GA15470@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E840447C54F@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E840447C54F@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

On Fri, Dec 23, 2005 at 12:03:27PM +0800, Zhang, Yanmin wrote:
> >>> +static struct sysfs_ops topology_sysfs_ops = {
> >>> +	.show   = topology_show,
> >>> +	.store  = topology_store,
> >>> +};
> >>> +
> >>> +static struct kobj_type topology_ktype = {
> >>> +	.sysfs_ops	= &topology_sysfs_ops,
> >>> +	.default_attrs	= topology_default_attrs,
> >>> +};
> >>> +
> >>> +/* Add/Remove cpu_topology interface for CPU device */
> >>> +static int __cpuinit topology_add_dev(struct sys_device * sys_dev)
> >>> +{
> >>> +	unsigned int cpu = sys_dev->id;
> >>> +
> >>> +	memset(&cpu_topology_kobject[cpu], 0, sizeof(struct kobject));
> >>> +
> >>> +	cpu_topology_kobject[cpu].parent = &sys_dev->kobj;
> >>> +	kobject_set_name(&cpu_topology_kobject[cpu], "%s", "topology");
> >>> +	cpu_topology_kobject[cpu].ktype = &topology_ktype;
> >>> +
> >>> +	return  kobject_register(&cpu_topology_kobject[cpu]);
> >>> +}
> >>
> >>Can't you just use an attribute group and attach it to the cpu kobject?
> >>That would save an array of kobjects I think.
> As you know, current i386/x86_64 arch also export cache info under
> /sys/device/system/cpu/cpuX/cache. Is it clearer to export topology
> under a new directory than under cpu directly?

No, the place in the sysfs tree you are putting this is just fine.  I'm
just saying that you do not need to create a new kobject for these
attributes.  Just use an attribute group, and you will get the same
naming, without the need for an extra kobject (and the whole array of
kobjects) at all.

Does that make more sense?

> >>> +static int __cpuinit topology_cpu_callback(struct notifier_block *nfb,
> >>> +		unsigned long action, void *hcpu)
> >>> +{
> >>> +	unsigned int cpu = (unsigned long)hcpu;
> >>> +	struct sys_device *sys_dev;
> >>> +
> >>> +	sys_dev = get_cpu_sysdev(cpu);
> >>> +	switch (action) {
> >>> +		case CPU_ONLINE:
> >>> +			topology_add_dev(sys_dev);
> >>> +			break;
> >>> +#ifdef	CONFIG_HOTPLUG_CPU
> >>> +		case CPU_DEAD:
> >>> +			topology_remove_dev(sys_dev);
> >>> +			break;
> >>> +#endif
> >>
> >>Why ifdef?  Isn't it safe to just always have this in?
> If no ifdef here, gcc reported a compiling warning when I compiled it
> on IA64 with CONFIG_HOTPLUG_CPU=n.

Then you should probably go change it so that CPU_DEAD is defined on
non-smp builds, otherwise the code gets quite messy like the above :)

thanks,

greg k-h
