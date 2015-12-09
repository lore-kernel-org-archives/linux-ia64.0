From: "Prakash, Prashanth" <pprakash@codeaurora.org>
Date: Wed, 09 Dec 2015 22:52:15 +0000
Subject: Re: [PATCH v3 0/5] ACPI / processor_idle: Add ACPI v6.0 LPI support
Message-Id: <5668B09F.70201@codeaurora.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>

Reviewed the patch-set and tested it on an ARM platform over the last couple
of days without any issues, so

Tested-by: Prashanth Prakash <pprakash@codeaurora.org>

Thanks,
Prashanth

On 12/2/2015 7:10 AM, Sudeep Holla wrote:
> ACPI 6.0 introduced LPI(Low Power Idle) states that provides an alternate
> method to describe processor idle states. It extends the specification
> to allow the expression of idle states like C-states selectable by the
> OSPM when a processor goes idle, but may affect more than one processor,
> and may affect other system components.
>
> LPI extensions leverages the processor container device(again introduced
> in ACPI 6.0) allowing to express which parts of the system are affected
> by a given LPI state. It defines the local power states for each node
> in a hierarchical processor topology. The OSPM can use _LPI object to
> select a local power state for each level of processor hierarchy in the
> system. They used to produce a composite power state request that is
> presented to the platform by the OSPM.
>
> Since multiple processors affect the idle state for any non-leaf hierarchy
> node, coordination of idle state requests between the processors is
> required. ACPI supports two different coordination schemes: Platform
> coordinated and  OS initiated.
>
> This series aims at providing basic and initial support for platform
> coordinated LPI states.
>
> v2[2]->v3:
> 	- rebased against v4.4-rc3
> 	- fixed couple of issues reported by Prashanth and review comments
> 	  from Ashwin
>
> v1[1]->v2[2]:
> 	- Fixed support for ACPI0010 processor container
> 	- moved sleep state code out of processor_idle
>
> Note the ARM64 specific changes are not part of this series as it's still
> WIP and there are other consolidation happening in there. For reference
> and testing, I have pushed a branch[3]
>
> Regards,
> Sudeep
>
> [1] https://lkml.org/lkml/2015/8/4/789
> [2] https://lkml.org/lkml/2015/9/16/422
> [3] git://git.kernel.org/pub/scm/linux/kernel/git/sudeep.holla/linux.git arm64_lpi_testing
>
>
> Sudeep Holla (5):
>   ACPI / processor : add support for ACPI0010 processor container
>   ACPI / sleep: move acpi_processor_sleep to sleep.c
>   ACPI / processor_idle: replace PREFIX with pr_fmt
>   ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
>   ACPI / processor_idle: Add support for Low Power Idle(LPI) states
>
>  arch/ia64/Kconfig               |   1 +
>  arch/x86/Kconfig                |   1 +
>  drivers/acpi/Kconfig            |   6 +
>  drivers/acpi/acpi_processor.c   |  17 ++
>  drivers/acpi/bus.c              |   8 +-
>  drivers/acpi/processor_driver.c |   4 +-
>  drivers/acpi/processor_idle.c   | 553 ++++++++++++++++++++++++++++++++--------
>  drivers/acpi/sleep.c            |  35 +++
>  include/acpi/processor.h        |  42 ++-
>  include/linux/acpi.h            |   4 +
>  10 files changed, 545 insertions(+), 126 deletions(-)
>

