From: Greg KH <greg@kroah.com>
Date: Tue, 27 Dec 2005 05:35:26 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <20051227053526.GD25886@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84044DE5EA@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84044DE5EA@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

On Mon, Dec 26, 2005 at 03:38:16PM +0800, Zhang, Yanmin wrote:
> >>> >>> +static int __cpuinit topology_cpu_callback(struct notifier_block *nfb,
> >>> >>> +		unsigned long action, void *hcpu)
> >>> >>> +{
> >>> >>> +	unsigned int cpu = (unsigned long)hcpu;
> >>> >>> +	struct sys_device *sys_dev;
> >>> >>> +
> >>> >>> +	sys_dev = get_cpu_sysdev(cpu);
> >>> >>> +	switch (action) {
> >>> >>> +		case CPU_ONLINE:
> >>> >>> +			topology_add_dev(sys_dev);
> >>> >>> +			break;
> >>> >>> +#ifdef	CONFIG_HOTPLUG_CPU
> >>> >>> +		case CPU_DEAD:
> >>> >>> +			topology_remove_dev(sys_dev);
> >>> >>> +			break;
> >>> >>> +#endif
> >>> >>
> >>> >>Why ifdef?  Isn't it safe to just always have this in?
> >>> If no ifdef here, gcc reported a compiling warning when I compiled it
> >>> on IA64 with CONFIG_HOTPLUG_CPU=n.
> >>
> >>Then you should probably go change it so that CPU_DEAD is defined on
> >>non-smp builds, otherwise the code gets quite messy like the above :)
> 
> Sorry. My previous explanation is confusing. It's a link warning on
> ia64. On ia64, the kernel vmlinux doesn't include section .exit.text,
> so ld will report a link warning when a function is in section
> .exit.text and another function (not in .exit.text) calls the first
> one. When CONFIG_HOTPLUG_CPU=n, function topology_remove_dev is in
> section .exit.text, but its caller topology_remove_dev is not in
> .exit.text.
> 
> i386 and x86_64 kernel vmlinux does include .exit.text and discard it
> only when running, so there is no such warning on i386/x86_64.
> 
> There is no other better approach to get rid of the warning unless we
> change arch/ia64/kernel/vmlinux.lds.S to keep all .exit.text in kernel
> image.

Or just move that function to not be __exit, as you are calling it from
an __init function.  That would be the best solution.

thanks,

greg k-h
