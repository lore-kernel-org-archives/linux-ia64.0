From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 09 Jan 2006 06:47:48 +0000
Subject: RE: [PATCH v3]Export cpu topology by sysfs
Message-Id: <8126E4F969BA254AB43EA03C59F44E8404693250@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104010658.A16342@unix-os.sc.intel.com>
In-Reply-To: <20060104010658.A16342@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Nathan Lynch <ntl@pobox.com>, Yanmin Zhang <ymzhang@unix-os.sc.intel.com>
Cc: linux-kernel@vger.kernel.org, greg@kroah.com, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kern=
el.org] On Behalf Of Nathan Lynch
>>Sent: 2006=C4=EA1=D4=C29=C8=D5 13:10
>>To: Yanmin Zhang
>>Cc: linux-kernel@vger.kernel.org; greg@kroah.com; discuss@x86-64.org; lin=
ux-ia64@vger.kernel.org; Siddha, Suresh B; Shah, Rajesh;
>>Pallipadi, Venkatesh
>>Subject: Re: [PATCH v3]Export cpu topology by sysfs
>>> 2) Set consistent default values for the 4 attributes.
>>>
>>
>><snip>
>>
>>> If one architecture wants to support this feature, it just needs to
>>> implement 4 defines, typically in file include/asm-XXX/topology.h.
>>> The 4 defines are:
>>> #define topology_physical_package_id(cpu)
>>> #define topology_core_id(cpu)
>>> #define topology_thread_siblings(cpu)
>>> #define topology_core_siblings(cpu)
>>>
>>> The type of **_id is int.
>>> The type of siblings is cpumask_t.
>>>
>>> To be consistent on all architectures, the 4 attributes should have
>>> deafult values if their values are unavailable. Below is the rule.
>>> 1) physical_package_id: If cpu has no physical package id, -1 is the
>>> default value.
>>> 2) core_id: If cpu doesn't support multi-core, its core id is 0.
>>
>>Why not -1 as with the physical package id?  0 could be a valid core
>>id.
If the cpu has only 1 core, we could call it single-core, so it's reasonabl=
e to use 0 as its core id.


>>
>>> 3) thread_siblings: Just include itself, if the cpu doesn't support
>>> HT/multi-thread.
>>> 4) core_siblings: Just include itself, if the cpu doesn't support
>>> multi-core and HT/Multi-thread.
>>
>>Really, I think the least confusing interface would not export those
>>attributes which are not relevant for the system.  E.g. if the system
>>isn't multi-core, you don't see core_id and core_siblings attributes.
>>
>>Failing that, let's at least have consistent, unambiguous values for
>>the ids which are not applicable.
Current kernel will output core id by /proc/cpuinfo if a physical cpu has 2=
 threads, no matter if it's a multi-core, or just a multi-thread. To be con=
sistent with /proc/cpuinfo, I think we need export core id and its default =
value is 0.

>>
>><snip>
>>> +static int __cpuinit topology_cpu_callback(struct notifier_block *nfb,
>>> +		unsigned long action, void *hcpu)
>>> +{
>>> +	unsigned int cpu =3D (unsigned long)hcpu;
>>> +	struct sys_device *sys_dev;
>>> +
>>> +	sys_dev =3D get_cpu_sysdev(cpu);
>>> +	switch (action) {
>>> +		case CPU_ONLINE:
>>> +			topology_add_dev(sys_dev);
>>> +			break;
>>> +		case CPU_DEAD:
>>> +			topology_remove_dev(sys_dev);
>>> +			break;
>>> +	}
>>> +	return NOTIFY_OK;
>>> +}
>>
>>I still oppose this bit.  I want the attributes there for powerpc even
>>for offline cpus -- the topology information (if obtainable, which it
>>is on powerpc) is useful regardless of the cpu's online state.  The
>>attributes should appear when a cpu is made present, and go away when
>>a cpu is removed.
As my previous email says, there are concerns/issues to do so. A compromise=
 is that the patch could register a sysdev driver. When the cpu becomes off=
line from online, we don't delete the topology kobj. The compromise has a d=
efect. If the cpu is never online since machine boots, the topology info of=
 the cpu is incorrect.=20

>>
>>This week I'll try to do an implementation for powerpc.
