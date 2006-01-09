From: Nathan Lynch <ntl@pobox.com>
Date: Mon, 09 Jan 2006 04:51:54 +0000
Subject: Re: [PATCH v2:3/3]Export cpu topology by sysfs
Message-Id: <20060109045153.GB2683@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <8126E4F969BA254AB43EA03C59F44E84045838F8@pdsmsx404>
In-Reply-To: <8126E4F969BA254AB43EA03C59F44E84045838F8@pdsmsx404>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Cc: Yanmin Zhang <ymzhang@unix-os.sc.intel.com>, greg@kroah.com, linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Shah, Rajesh" <rajesh.shah@intel.com>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>

Zhang, Yanmin wrote:
> >>> >>I don't think it makes much sense to add and remove the attribute
> >>> >>group for cpu online/offline events.  The topology information for an
> >>> >>offline cpu is potentially valuable -- it could help the admin decide
> >>> >>which processor to online at runtime, for example.
> >>> >>
> >>> >>I believe the correct time to update the topology information is when
> >>> >>the topology actually changes (e.g. physical addition or removal of a
> >>> >>processor) -- this is independent of online/offline operations.
> >>>
> >>> Currently, on i386/x86_64/ia64, a cpu gets its own topology by
> >>> itself and fills into a global array. If the cpu is offline since
> >>> the machine is booted, we can't get its topology info.
> >>
> >>Hmm, is this a limitation of those architectures?  On ppc64 (where
> >>this feature would be applicable) Open Firmware provides such topology
> >>information regardless of the cpus' states; does the firmware or ACPI
> >>on these platforms not do the same?
>
> On I386/x86_64/IA64, MADT, an ACPI table, provides apic id for all
> cpus. But we can't divide it to get core id and thread id becasue we
> couldn't know how many bits of apic id are for core id and how many
> bits are for thread id. These info are got only by executing cupid
> (on i386/x86_64) or PAL call (on ia64) by the online cpu itself.

In practice does the division of bits between core and thread in the
apic id differ between cpus in the same system?  Is there really no
way to discover a cpu's core and thread id without onlining it on
these platforms?
