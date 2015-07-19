From: Mathias Krause <minipli@googlemail.com>
Date: Sun, 19 Jul 2015 15:05:40 +0000
Subject: [PATCH 0/3] ia64: Remove unneeded __ref / __refdata annotations
Message-Id: <1437318343-13152-1-git-send-email-minipli@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This series removes unneeded __ref / __refdata annotations that have
become mostly obsolete since the __cpuinit removal in v3.11.

Please apply.

Mathias Krause (3):
  ACPI / ia64: Get rid of the acpi_map_cpu() wrapper
  ia64, topology: Remove bogus __ref annotations
  ia64, palinfo: Remove bogus __refdata annotation

 arch/ia64/kernel/acpi.c     |    8 +-------
 arch/ia64/kernel/palinfo.c  |    2 +-
 arch/ia64/kernel/topology.c |    4 ++--
 3 files changed, 4 insertions(+), 10 deletions(-)

-- 
1.7.10.4

