From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Mon, 09 Jan 2006 06:35:36 +0000
Subject: RE: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <8126E4F969BA254AB43EA03C59F44E840469321C@pdsmsx404>
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
>>Sent: 2006=C4=EA1=D4=C29=C8=D5 12:52
>>To: Zhang, Yanmin
>>Cc: Yanmin Zhang; greg@kroah.com; linux-kernel@vger.kernel.org; discuss@x=
86-64.org; linux-ia64@vger.kernel.org; Siddha, Suresh B; Shah,
>>Rajesh; Pallipadi, Venkatesh
>>Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
>>
>>Zhang, Yanmin wrote:
>>> >>> >>I don't think it makes much sense to add and remove the attribute
>>> >>> >>group for cpu online/offline events.  The topology information fo=
r an
>>> >>> >>offline cpu is potentially valuable -- it could help the admin de=
cide
>>> >>> >>which processor to online at runtime, for example.
>>> >>> >>
>>> >>> >>I believe the correct time to update the topology information is =
when
>>> >>> >>the topology actually changes (e.g. physical addition or removal =
of a
>>> >>> >>processor) -- this is independent of online/offline operations.
>>> >>>
>>> >>> Currently, on i386/x86_64/ia64, a cpu gets its own topology by
>>> >>> itself and fills into a global array. If the cpu is offline since
>>> >>> the machine is booted, we can't get its topology info.
>>> >>
>>> >>Hmm, is this a limitation of those architectures?  On ppc64 (where
>>> >>this feature would be applicable) Open Firmware provides such topology
>>> >>information regardless of the cpus' states; does the firmware or ACPI
>>> >>on these platforms not do the same?
>>>
>>> On I386/x86_64/IA64, MADT, an ACPI table, provides apic id for all
>>> cpus. But we can't divide it to get core id and thread id becasue we
>>> couldn't know how many bits of apic id are for core id and how many
>>> bits are for thread id. These info are got only by executing cupid
>>> (on i386/x86_64) or PAL call (on ia64) by the online cpu itself.
>>
>>In practice does the division of bits between core and thread in the
>>apic id differ between cpus in the same system?
On i386 and x86_64, I think the answer is no, so we could get core and thre=
ad id for offline cpu. But there are 2 concerns.
1) Current cpu hotplug supports to convert cpu state between online and cpu=
line. In the future, the implementation would add support conversion betwee=
n non-present and present. If a cpu is not present, there might be no its c=
orresponding MADT entry. Later, when the cpu becomes present, ACPI needs pr=
ovide its apic id dynamically. As for this case, we still can't get the non=
-present cpu id.
2) On ia64, ia64 manual says that cpu physical id/core id/thread id are got=
 by pal call. It doesn't mention how to divide apic id to get physical id/c=
ore id/thread id.

  Is there really no
>>way to discover a cpu's core and thread id without onlining it on
>>these platforms?
