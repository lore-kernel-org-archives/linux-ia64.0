From: Sudeep Holla <sudeep.holla@arm.com>
Date: Tue, 04 Aug 2015 17:46:42 +0000
Subject: [PATCH 0/4] ACPI / core : few cleanups and updates for LPI
Message-Id: <1438710406-3822-1-git-send-email-sudeep.holla@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org

Hi Rafael,

I am working on adding Low Power Idle(LPI) states support that was
recently added in ACPI 6.0. Before introducing the LPI support, here
are few updates and cleanups/re-organisation so that LPI support can be
added to processor_idle module to co-exist with C-state.

Regards,
Sudeep

Sudeep Holla (4):
  ACPI / processor : add support for ACPI0010 processor container
  ACPI / sleep: move acpi_processor_sleep to sleep.c
  ACPI / processor_idle: replace PREFIX with pr_fmt
  ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE

 arch/ia64/Kconfig             |   1 +
 arch/x86/Kconfig              |   1 +
 drivers/acpi/Kconfig          |   3 ++
 drivers/acpi/acpi_processor.c |  17 ++++++
 drivers/acpi/processor_idle.c | 119 +++++++++++++++++++-----------------------
 drivers/acpi/sleep.c          |  37 +++++++++++++
 include/acpi/processor.h      |   6 ++-
 7 files changed, 116 insertions(+), 68 deletions(-)

-- 
1.9.1

