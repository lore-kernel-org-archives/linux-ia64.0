From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 16 Sep 2015 13:59:18 +0000
Subject: [PATCH v2 0/5] ACPI / processor_idle: Add ACPIv6.0 LPI support
Message-Id: <1442411963-14398-1-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>

ACPI 6.0 introduced LPI(Low Power Idle) states that provides an alternate
method to describe processor idle states. It extends the specification
to allow the expression of idle states like C-states selectable by the
OSPM when a processor goes idle, but may affect more than one processor,
and may affect other system components.

LPI extensions leverages the processor container device(again introduced
in ACPI 6.0) allowing to express which parts of the system are affected
by a given LPI state. It defines the local power states for each node
in a hierarchical processor topology. The OSPM can use _LPI object to
select a local power state for each level of processor hierarchy in the
system. They used to produce a composite power state request that is
presented to the platform by the OSPM.

Since multiple processors affect the idle state for any non-leaf hierarchy
node, coordination of idle state requests between the processors is
required. ACPI supports two different coordination schemes: Platform
coordinated and  OS initiated.

This series aims at providing basic and initial support for platform
coordinated LPI states.

Sudeep Holla (5):
  ACPI / processor : add support for ACPI0010 processor container
  ACPI / sleep: move acpi_processor_sleep to sleep.c
  ACPI / processor_idle: replace PREFIX with pr_fmt
  ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
  ACPI / processor_idle: Add support for Low Power Idle(LPI) states

 arch/ia64/Kconfig               |   1 +
 arch/x86/Kconfig                |   1 +
 drivers/acpi/Kconfig            |   6 +
 drivers/acpi/acpi_processor.c   |  17 ++
 drivers/acpi/bus.c              |   8 +-
 drivers/acpi/processor_driver.c |   4 +-
 drivers/acpi/processor_idle.c   | 525 +++++++++++++++++++++++++++++++---------
 drivers/acpi/sleep.c            |  35 +++
 include/acpi/processor.h        |  38 ++-
 include/linux/acpi.h            |   4 +
 10 files changed, 515 insertions(+), 124 deletions(-)

-- 
1.9.1

