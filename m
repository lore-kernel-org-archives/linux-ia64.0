From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Mar 2004 15:57:36 +0000
Subject: Re: [PATCH] current  ( was  RE: cat /proc/acpi/events bad for your system's health!)
Message-Id: <16472.30064.241919.899417@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401CBB762@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401CBB762@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Mar 2004 20:48:00 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  >> The main difference with 2.4 is signal_pending. From ACPI log, I
  >> also noticed that the thread waiting on acpi_bus_event_queue
  >> didn't resume proberly, because there is no exit message of
  >> acpi_bus_receive_event in ACPI log as expected if you turn on
  >> full debug flag of acpi.

  Luming> After comparing the disassembly code of
  Luming> acpi_bus_receive_event() , I find the following difference
  Luming> introduced by my workaround:

  Luming> 155c155
  Luming>  12d0:     00 00 00 1a b8 11       [MII]       st8.rel [r13]=r0
  Luming> ---
  Luming>  12d0:     00 40 00 1a b8 15       [MII]       st8.rel [r13]=r0,8


  Luming> Perhaps, gcc did something wrong with
  Luming> set_current_state(TASK_RUNNING).  Because r13 intend for
  Luming> pointer to the current task.

How nasty!  Your hunch about bad code-generation was right, after all!

  Luming> The following is my patch, which can fix this issue.

  Luming> -		{
  Luming> \
  Luming> -			register __u64 ia64_r13 asm ("r13");
  Luming> \
  Luming> -			ia64_intri_res = ia64_r13;
  Luming> \
  Luming> -		}
  Luming> \
  Luming> +		asm volatile ("mov %0=r13" : "=r"(ia64_intri_res));

Unfortunately, this leads to worse-quality code.  I think we may have
to resort to an #ifdef __INTEL_COMPILER in <asm-ia64/current.h> so
that we can use a global register for GCC as we used to.  I'll look
into this today.

Thanks,

	--david
