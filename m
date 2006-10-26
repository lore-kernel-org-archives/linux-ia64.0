From: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Date: Thu, 26 Oct 2006 04:36:58 +0000
Subject: RE: ia64 acpi-cpufreq driver
Message-Id: <EB12A50964762B4D8111D55B764A8454C96410@scsmsx413.amr.corp.intel.com>
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
>Sent: Wednesday, October 25, 2006 4:21 PM
>To: Pallipadi, Venkatesh
>Cc: linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org
>Subject: Re: ia64 acpi-cpufreq driver
>
>On Monday 23 October 2006 22:46, Pallipadi, Venkatesh wrote:
>> >Section 8.4.4.1 (_PCT) of the 3.0 ACPI spec says:
>> >
>> >  OSPM performs processor performance transitions by writing
>> >  the performance state-specific control value to a Performance
>> >  Control Register (PERF_CTRL).
>> >
>> >According to one of our architecture guys, this means we really
>> >ought to have an OpRegion driver that encapsulates the 
>PAL_SET_PSTATE
>> >call.
>> 
>> Actually it is slightly different from low_level_read and write. 
>> Generic ACPI definition of ACPI PERF_CTRL and PERF_STATUS define 
>> them as if they are registers. But, with FfixedHW, ACPI allows 
>> architectures to implement this functionality in a native way.
>
>I'd like to understand this better.  Something like the following
>patch (not for inclusion, may not even compile) is what I'm
>thinking.  This seems more in line with the spec intent.
>
>Apart from details like "bit_width <= 8" vs. "bit_width = 8",
>this should be functionally the same.  Are you saying it's different
>because of those details, or is there a larger difference I don't
>understand?
>

Yes. Something like this will work. I don't think it is the intent of
the SPEC. As I understand, FFH in SPEC is intended to be used whenever
we have hardware/processor specific interfaces (As described in ACPI 3.0
spec - page 46). Also, it will complicate the code. I think having
separate code, even if there is some amount of duplication is there, is
better in this case. The reasons:
- i386 acpi-cpufreq code has support for both IO port and FFH. Please
refer to arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c in 2.6.19-rc2-mm2,
which is a lot different from current git.
 
- FFH in i386 works in a different way from IPF. Specifically,
PERF_STATUS is just a register read, and hardware performance feedback
is by using different APERF/MPERF MSR. But, in IPF it is done through
passing a different type parameter to same PAL_GET_PSTATE calls (will be
adding this to IPF driver soon).

Thanks,
Venki
