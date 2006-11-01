From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Wed, 01 Nov 2006 18:30:21 +0000
Subject: RE: ia64 acpi-cpufreq driver
Message-Id: <EB12A50964762B4D8111D55B764A8454D03557@scsmsx413.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610231531.05346.bjorn.helgaas@hp.com>
In-Reply-To: <200610231531.05346.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

 

>-----Original Message-----
>From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com] 
>Sent: Thursday, October 26, 2006 8:30 AM
>To: Pallipadi, Venkatesh
>Cc: linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org
>Subject: Re: ia64 acpi-cpufreq driver
>> I think having 
>> separate code, even if there is some amount of duplication 
>is there, is
>> better in this case. The reasons:
>> - i386 acpi-cpufreq code has support for both IO port and FFH. Please
>> refer to arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c in 
>2.6.19-rc2-mm2,
>> which is a lot different from current git.
>> - FFH in i386 works in a different way from IPF. Specifically,
>> PERF_STATUS is just a register read, and hardware 
>performance feedback
>> is by using different APERF/MPERF MSR. But, in IPF it is done through
>> passing a different type parameter to same PAL_GET_PSTATE 
>calls (will be
>> adding this to IPF driver soon).
>
>Well, of course FFH would be *implemented* differently on x86
>than ia64!  But the layout of the FFH address space, which
>essentially determines the semantics of FFH, should be the
>same for all architectures (though somebody seems to have
>forgotten to specify that layout).
>

What I meant is, way FFH address space is defined and used is not
totally 
same across i386 and ia64. Specifically, FFH is only used in definition
of 
_PCT status and control objects and a FFH driver can be useful there.
But,
Hardware feedback of current/average frequency over a period of time 
(which does not have FFH object in ACPI) can also use some interface 
which overlap with interface that FFH driver is using. In the sense that
There is no clear distinction on the scope of this FFH driver.
Also i386 uses FFH for both C-states and P-states where as IA64 uses it
only for P-states today.

All this issues can be resolved once we have a definition of this FFH
scope.
I guess we need to revisit once we have the FFH related documentation
for IA64
(which should happen soon).

But, having seen the undue complications we are having in i386 world
with 
different drivers (SYSTEM_IO and FFH drivers) and stuff my feeling at
this
point is, it will just add more overhead due to abstraction than the
commonality in code that it is going to bring. I mean, all the cpufreq
and
ACPI code are already getting shared across architectures today. So,
only 
thing this new abstraction is going to make common across archs is
registering and deregistering with ACPI and cpufreq.


Thanks,
Venki
