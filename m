From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Sat, 31 Dec 2005 08:43:24 +0000
Subject: RE: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <8126E4F969BA254AB43EA03C59F44E84045838F8@pdsmsx404>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051220180929.B19129@unix-os.sc.intel.com>
In-Reply-To: <20051220180929.B19129@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Nathan Lynch <ntl@pobox.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, greg@kroah.com, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-owner@vger.kern=
el.org] On Behalf Of Nathan Lynch
>>Sent: 2005=C4=EA12=D4=C229=C8=D5 3:14
>>To: Zhang, Yanmin
>>Cc: Yanmin Zhang; greg@kroah.com; linux-kernel@vger.kernel.org; discuss@x=
86-64.org; linux-ia64@vger.kernel.org; Siddha, Suresh B; Shah,
>>Rajesh; Pallipadi, Venkatesh
>>Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
>>
>>
>>> >>What about sane default values for the *_id attributes?
>>Not really -- inevitably we'll wind up with an interface that has
>>slightly different semantics on each architecture.
How about below arrangement for default values?
1) physical_package_id: If cpu has no physical package id, the logical cpu =
id will be picked up.
2) core_id: 0. If cpu doesn't support multi-core, its core id is 0.=20
3) thread_siblings: Just include itself, if the cpu doesn't support HT/mult=
i-thread.
4) core_siblings: Just include itself, if the cpu doesn't support multi-cor=
e and HT.


>>
>>> >>Hmm, why should thread_id be exported at all?  Is it useful to
>>> >>userspace in a way that the logical cpu id is not?
>>>
>>> Just to make it clearer. Of course, physical_package_id /core_id/
>>> logical cpu id could tell enough info like thread id.
>>
>>Then let's drop thread_id until there's a need for it.
Ok.=20


>>> >>> +	switch (action) {
>>> >>> +		case CPU_ONLINE:
>>> >>> +			topology_add_dev(sys_dev);
>>> >>> +			break;
>>> >>> +		case CPU_DEAD:
>>> >>> +			topology_remove_dev(sys_dev);
>>> >>> +			break;
>>> >>> +	}
>>> >>> +	return NOTIFY_OK;
>>> >>> +}
>>> >>
>>> >>I don't think it makes much sense to add and remove the attribute
>>> >>group for cpu online/offline events.  The topology information for an
>>> >>offline cpu is potentially valuable -- it could help the admin decide
>>> >>which processor to online at runtime, for example.
>>> >>
>>> >>I believe the correct time to update the topology information is when
>>> >>the topology actually changes (e.g. physical addition or removal of a
>>> >>processor) -- this is independent of online/offline operations.
>>>
>>> Currently, on i386/x86_64/ia64, a cpu gets its own topology by
>>> itself and fills into a global array. If the cpu is offline since
>>> the machine is booted, we can't get its topology info.
>>
>>Hmm, is this a limitation of those architectures?  On ppc64 (where
>>this feature would be applicable) Open Firmware provides such topology
>>information regardless of the cpus' states; does the firmware or ACPI
>>on these platforms not do the same?
On I386/x86_64/IA64, MADT, an ACPI table, provides apic id for all cpus. Bu=
t we can't divide it to get core id and thread id becasue we couldn't know =
how many bits of apic id are for core id and how many bits are for thread i=
d. These info are got only by executing cupid (on i386/x86_64) or PAL call =
(on ia64) by the online cpu itself.

>>
>>> And when a cpu is offline, current kernel deletes it from the
>>> thread_siblings and core_siblings of other cpu.
>>
>>That's fine -- I'm just arguing against the addition/removal of the
>>attributes when cpus go online and offline.
Based on above discussion, if the attributes of the cpu is not removed when=
 the cpu is offline, the attribute values might be incorrect when the cpu i=
s not up since machine boots.

