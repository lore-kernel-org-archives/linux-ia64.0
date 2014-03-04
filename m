From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 04 Mar 2014 21:07:31 +0000
Subject: [PATCH 0/2] sched: Removed unused mc_capable() and smt_capable()
Message-Id: <20140304210621.16893.8772.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

This is just cleanup of a couple unused interfaces and (for sparc64) a
supporting variable.

---

Bjorn Helgaas (2):
      sched: Remove unused mc_capable() and smt_capable()
      sparc64: Remove unused sparc64_multi_core


 arch/arm/include/asm/topology.h      |    3 ---
 arch/ia64/include/asm/topology.h     |    1 -
 arch/mips/include/asm/topology.h     |    4 ----
 arch/powerpc/include/asm/topology.h  |    1 -
 arch/sparc/include/asm/smp_64.h      |    1 -
 arch/sparc/include/asm/topology_64.h |    2 --
 arch/sparc/kernel/mdesc.c            |    4 ----
 arch/sparc/kernel/prom_64.c          |    3 ---
 arch/sparc/kernel/smp_64.c           |    2 --
 arch/x86/include/asm/topology.h      |    6 ------
 10 files changed, 27 deletions(-)
