From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 26 Dec 2005 07:38:16 +0000
Subject: RE: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <8126E4F969BA254AB43EA03C59F44E84044DE5EA@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051220180929.B19129@unix-os.sc.intel.com>
In-Reply-To: <20051220180929.B19129@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Greg KH <greg@kroah.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

>>-----Original Message-----
>>From: Greg KH [mailto:greg@kroah.com]
>>Sent: 2005=C4=EA12=D4=C224=C8=D5 3:16
>>To: Zhang, Yanmin
>>Cc: Yanmin Zhang; linux-kernel@vger.kernel.org; discuss@x86-64.org; linux=
-ia64@vger.kernel.org; Siddha, Suresh B; Shah, Rajesh;
>>Pallipadi, Venkatesh
>>Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
>>
>>On Fri, Dec 23, 2005 at 12:03:27PM +0800, Zhang, Yanmin wrote:
>>> >>Can't you just use an attribute group and attach it to the cpu kobjec=
t?
>>> >>That would save an array of kobjects I think.
>>> As you know, current i386/x86_64 arch also export cache info under
>>> /sys/device/system/cpu/cpuX/cache. Is it clearer to export topology
>>> under a new directory than under cpu directly?
>>
>>No, the place in the sysfs tree you are putting this is just fine.  I'm
>>just saying that you do not need to create a new kobject for these
>>attributes.  Just use an attribute group, and you will get the same
>>naming, without the need for an extra kobject (and the whole array of
>>kobjects) at all.
>>
>>Does that make more sense?
Yes, indeed. Now, I used your idea and the patch became simpler. Thanks.


>>
>>> >>> +static int __cpuinit topology_cpu_callback(struct notifier_block *=
nfb,
>>> >>> +		unsigned long action, void *hcpu)
>>> >>> +{
>>> >>> +	unsigned int cpu =3D (unsigned long)hcpu;
>>> >>> +	struct sys_device *sys_dev;
>>> >>> +
>>> >>> +	sys_dev =3D get_cpu_sysdev(cpu);
>>> >>> +	switch (action) {
>>> >>> +		case CPU_ONLINE:
>>> >>> +			topology_add_dev(sys_dev);
>>> >>> +			break;
>>> >>> +#ifdef	CONFIG_HOTPLUG_CPU
>>> >>> +		case CPU_DEAD:
>>> >>> +			topology_remove_dev(sys_dev);
>>> >>> +			break;
>>> >>> +#endif
>>> >>
>>> >>Why ifdef?  Isn't it safe to just always have this in?
>>> If no ifdef here, gcc reported a compiling warning when I compiled it
>>> on IA64 with CONFIG_HOTPLUG_CPU=3Dn.
>>
>>Then you should probably go change it so that CPU_DEAD is defined on
>>non-smp builds, otherwise the code gets quite messy like the above :)

Sorry. My previous explanation is confusing. It's a link warning on ia64. O=
n ia64, the kernel vmlinux doesn't include section .exit.text, so ld will r=
eport a link warning when a function is in section .exit.text and another f=
unction (not in .exit.text) calls the first one. When CONFIG_HOTPLUG_CPU=3D=
n, function topology_remove_dev is in section .exit.text, but its caller to=
pology_remove_dev is not in .exit.text.

i386 and x86_64 kernel vmlinux does include .exit.text and discard it only =
when running, so there is no such warning on i386/x86_64.

There is no other better approach to get rid of the warning unless we chang=
e arch/ia64/kernel/vmlinux.lds.S to keep all .exit.text in kernel image.

