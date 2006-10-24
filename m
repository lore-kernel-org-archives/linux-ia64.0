From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Tue, 24 Oct 2006 23:59:24 +0000
Subject: RE: ia64 acpi-cpufreq driver
Message-Id: <EB12A50964762B4D8111D55B764A8454C95BB5@scsmsx413.amr.corp.intel.com>
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
>Sent: Tuesday, October 24, 2006 10:51 AM
>To: Pallipadi, Venkatesh
>Cc: linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org
>Subject: Re: ia64 acpi-cpufreq driver
>
>On Monday 23 October 2006 22:46, Pallipadi, Venkatesh wrote:
>> Actually it is slightly different from low_level_read and write. 
>> Generic ACPI definition of ACPI PERF_CTRL and PERF_STATUS define 
>> them as if they are registers. But, with FfixedHW, ACPI allows 
>> architectures to implement this functionality in a native way.
>> Just like x86 implements FfixedHW based P-state support in 16 bits 
>> of some known MSR (Note the register field itself in _PCT is 
>not used)
>> or FFH C-states are supported by native instructions like "hlt",
>> "monitor-mwait".
>> 
>> So, when firmware tells P-state are FFH, OS will look at the 
>hardware 
>> and processor information and use appropriate native interfaces. 
>> In this case, appropriate native interface is PAL_GET_PSTATE 
>> and PAL_SET_PSTATE.
>
>Clearly ia64 ultimately has to use PAL_SET_PSTATE.  My question
>is, does the PAL_SET_PSTATE call belong in acpi-cpufreq, or does
>it belong in the FFH driver?
>
>I think it belongs in the latter, because the OSPM can be more
>generic if the architecture-specific stuff is in the FFH driver.
>
>Another way to ask this is, if ia64 had an FFH driver, who would
>use it?  I assume acpi-cpufreq would be one user.  If so, what
>interface would acpi-cpufreq use to access FFH?
>

Yes. As it is today, acpi-cpufreq contains FFH driver functionality 
in itself. It calls acpi and cpufreq arch-independent interfaces but 
implements FFH internally. 

By, FFH driver do you mean to handle FFH related functions only for 
P-states or something that can handle all FFH functions (like C-states,
etc). 
I don't see any other kernel part/or driver will use this particular 
PAL_GET_PSTATE and PAL_SET_PSTATE intefaces. So, my feeling is we don't
need a separate FFH driver.

Thanks,
Venki
