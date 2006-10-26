From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 26 Oct 2006 15:29:59 +0000
Subject: Re: ia64 acpi-cpufreq driver
Message-Id: <200610260929.59672.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EB12A50964762B4D8111D55B764A8454C96410@scsmsx413.amr.corp.intel.com>
In-Reply-To: <EB12A50964762B4D8111D55B764A8454C96410@scsmsx413.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Wednesday 25 October 2006 22:36, Pallipadi, Venkatesh wrote:
> Yes. Something like this will work. I don't think it is the intent of
> the SPEC. As I understand, FFH in SPEC is intended to be used whenever
> we have hardware/processor specific interfaces (As described in ACPI 3.0
> spec - page 46). Also, it will complicate the code.

It sure looks like the intent to me.  Why would you bother with
the concept of FFH at all unless it provided some abstraction?
Abstraction can help simplify the code: you can use the same
code for multiple architectures, with differences encapsulated
in the per-arch FFH driver.

> I think having 
> separate code, even if there is some amount of duplication is there, is
> better in this case. The reasons:
> - i386 acpi-cpufreq code has support for both IO port and FFH. Please
> refer to arch/i386/kernel/cpu/cpufreq/acpi-cpufreq.c in 2.6.19-rc2-mm2,
> which is a lot different from current git.
> - FFH in i386 works in a different way from IPF. Specifically,
> PERF_STATUS is just a register read, and hardware performance feedback
> is by using different APERF/MPERF MSR. But, in IPF it is done through
> passing a different type parameter to same PAL_GET_PSTATE calls (will be
> adding this to IPF driver soon).

Well, of course FFH would be *implemented* differently on x86
than ia64!  But the layout of the FFH address space, which
essentially determines the semantics of FFH, should be the
same for all architectures (though somebody seems to have
forgotten to specify that layout).

There's nothing really x86-specific about i386/.../acpi-cpufreq,
except for the whole mess about supporting I/O ports, MSRs, etc.
If we made an x86 FFH OpRegion driver that knew how to do the MSR
stuff, we could probably use the same acpi-cpufreq driver across
x86 and ia64.
