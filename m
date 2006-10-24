From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Tue, 24 Oct 2006 04:46:58 +0000
Subject: RE: ia64 acpi-cpufreq driver
Message-Id: <EB12A50964762B4D8111D55B764A8454C57982@scsmsx413.amr.corp.intel.com>
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
>Sent: Monday, October 23, 2006 2:31 PM
>To: Pallipadi, Venkatesh
>Cc: linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org
>Subject: ia64 acpi-cpufreq driver
>
>arch/ia64/kernel/cpufreq/acpi-cpufreq.c currently makes direct
>calls to PAL_SET_PSTATE.
>
>Section 8.4.4.1 (_PCT) of the 3.0 ACPI spec says:
>
>  OSPM performs processor performance transitions by writing
>  the performance state-specific control value to a Performance
>  Control Register (PERF_CTRL).
>
>According to one of our architecture guys, this means we really
>ought to have an OpRegion driver that encapsulates the PAL_SET_PSTATE
>call.
>

Actually it is slightly different from low_level_read and write. 
Generic ACPI definition of ACPI PERF_CTRL and PERF_STATUS define 
them as if they are registers. But, with FfixedHW, ACPI allows 
architectures to implement this functionality in a native way.
Just like x86 implements FfixedHW based P-state support in 16 bits 
of some known MSR (Note the register field itself in _PCT is not used)
or FFH C-states are supported by native instructions like "hlt",
"monitor-mwait".

So, when firmware tells P-state are FFH, OS will look at the hardware 
and processor information and use appropriate native interfaces. 
In this case, appropriate native interface is PAL_GET_PSTATE 
and PAL_SET_PSTATE.

>This sort of makes sense to me, because it would mean this part
>of acpi-cpufreq wouldn't need to be ia64-specific.  On x86, I
>suppose _PCT would return a ACPI_ADR_SPACE_SYSTEM_IO address,
>and acpi_processor_set_performance() could use 
>acpi_hw_low_level_write()
>instead of its own acpi_processor_write_port().
>
>But I haven't seen anything resembling an ACPI FFH OpRegion
>driver for Linux, or even a spec (e.g., a definition of what
>the FFH address space contains) that would allow such a driver
>to be written.
>
>Any hints on what the future might hold in this area?

FFH by nature is specific to hardware and we will have to 
have arch specific driver to handle things. However, 
At present there is a missing documentation to link this 
ACPI FFH to Itanium Software Developers Manual's PAL_GET_PSTATE
and PAL_SET_PSTATE. There is a document that is in the works
and should go online real soon.

Thanks,
Venki
