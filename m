From: Greg KH <greg@kroah.com>
Date: Fri, 23 Dec 2005 00:16:43 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <20051223001643.GA3088@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051220180929.B19129@unix-os.sc.intel.com>
In-Reply-To: <20051220180929.B19129@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>
Cc: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, yanmin.zhang@intel.com, suresh.b.siddha@intel.com, rajesh.shah@intel.com, venkatesh.pallipadi@intel.com

On Tue, Dec 20, 2005 at 06:09:29PM -0800, Yanmin Zhang wrote:
> --- linux-2.6.15-rc5/drivers/base/topology.c	1970-01-01 08:00:00.000000000 +0800
> +++ linux-2.6.15-rc5_topology/drivers/base/topology.c	2005-12-20 00:33:49.000000000 +0800
> @@ -0,0 +1,201 @@
> +/*
> + * driver/base/topology.c - Populate driverfs with cpu topology information

driverfs?  Where did you cut/paste this code from?

And why does it have to be in driver/base?

> +struct _topology_attr {
> +	struct attribute attr;
> +	ssize_t (*show)(int cpu, char *);
> +	ssize_t (*store)(const char *, size_t count);
> +};

Don't put a '_' at the beginning of a structure please.

> +static ssize_t topology_show(struct kobject * kobj, struct attribute * attr, char * buf)
> +{
> +	unsigned int cpu;
> +        struct _topology_attr *fattr = to_attr(attr);
> +        ssize_t ret;
> +
> +	cpu = container_of(kobj->parent, struct sys_device, kobj)->id;
> +        ret = fattr->show ? fattr->show(cpu, buf): 0;
> +        return ret;
> +}

Mix of spaces and tabs :(

> +static ssize_t topology_store(struct kobject * kobj, struct attribute * attr,
> +		     const char * buf, size_t count)
> +{
> +	return 0;
> +}

Why is this function even needed?

> +static struct sysfs_ops topology_sysfs_ops = {
> +	.show   = topology_show,
> +	.store  = topology_store,
> +};
> +
> +static struct kobj_type topology_ktype = {
> +	.sysfs_ops	= &topology_sysfs_ops,
> +	.default_attrs	= topology_default_attrs,
> +};
> +
> +/* Add/Remove cpu_topology interface for CPU device */
> +static int __cpuinit topology_add_dev(struct sys_device * sys_dev)
> +{
> +	unsigned int cpu = sys_dev->id;
> +
> +	memset(&cpu_topology_kobject[cpu], 0, sizeof(struct kobject));
> +
> +	cpu_topology_kobject[cpu].parent = &sys_dev->kobj;
> +	kobject_set_name(&cpu_topology_kobject[cpu], "%s", "topology");
> +	cpu_topology_kobject[cpu].ktype = &topology_ktype;
> +
> +	return  kobject_register(&cpu_topology_kobject[cpu]);
> +}

Can't you just use an attribute group and attach it to the cpu kobject?
That would save an array of kobjects I think.

> +static int __cpuinit topology_cpu_callback(struct notifier_block *nfb,
> +		unsigned long action, void *hcpu)
> +{
> +	unsigned int cpu = (unsigned long)hcpu;
> +	struct sys_device *sys_dev;
> +
> +	sys_dev = get_cpu_sysdev(cpu);
> +	switch (action) {
> +		case CPU_ONLINE:
> +			topology_add_dev(sys_dev);
> +			break;
> +#ifdef	CONFIG_HOTPLUG_CPU
> +		case CPU_DEAD:
> +			topology_remove_dev(sys_dev);
> +			break;
> +#endif

Why ifdef?  Isn't it safe to just always have this in?

thanks,

greg k-h
