From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 10 Jun 2008 07:46:56 +0000
Subject: [PATCH 00/27] ia64/xen domU take 7
Message-Id: <12130840433561-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. This patchset implements ia64/xen domU support based on
ia64/pv_ops frame work which was already merged to linux ia64 test branch.
This patch is for linux ia64 test branch.

This patchset does the followings.
- Some preparation work. Mainly importing header files to define
  related structures.
- Then, define functions related to hypercall which is the way to
  communicate with Xen hypervisor.
- Add some helper functions which is necessary to utilize
  xen arch generic portion.
- Next implements the xen instance of pv_ops introducing
  pv_info, pv_init_ops, pv_cpu_ops and its assembler counter part,
  pv_iosapic_ops, pv_irq_ops and, pv_time_ops step by step.
- Introduce xen machine vector to describe xen platform.
  By using machine vector, xen domU implementation can be simplified.
- Lastly update Kconfig to allow paravirtualization support and
  xen domU support to compile.


The working full source is available from
http://people.valinux.co.jp/~yamahata/xen-ia64/for_eagl/linux-2.6-ia64-pv-ops.git/
branch: ia64-pv-ops-2008june10-xen-ia64

For the status of this patch series
http://wiki.xensource.com/xenwiki/XenIA64/UpstreamMerge

At this phase, we don't address the following issues.
Those will be addressed after the first merge.
- optimization by binary patch
  In fact, we had the patch to do that, but we intentionally dropped
  for patch size/readability/cleanness.
- freeing the unused pages, i.e. pages for unused ivt.S.
- complete save/restore support

Changes from take 6:
- rebased to linux ia64 test branch
- xen bsw_1 simplification.
- add documentation. Documentation/ia64/xen.txt
- preliminary support for save/restore.
- network fix. NET_SKB_PAD.

Changes from take 5:
- rebased to Linux 2.6.26-rc3
- fix ivt.S paravirtualization.
  One instruction was wrongly paravirtualized.
  It wasn't revealed with Xen HVM domain so far, but with real hw
- multi entry point support.
- revised changelog to add CCs.

Changes from take 4:
- fix synch bit ops definitions to prevent accidental namespace clashes.
- rebased and fixed breakages due to the upstream change.

Changes from take 3:
- split the patch set into pv_op part and xen domU part.
- many clean ups.
- introduced pv_ops: pv_cpu_ops and pv_time_ops.

Changes from take 2:
- many clean ups following to comments.
- clean up:assembly instruction macro.
- introduced pv_ops: pv_info, pv_init_ops, pv_iosapic_ops, pv_irq_ops.

Changes from take 1:
Single IVT source code. compile multitimes using assembler macros.

thanks,

Diffstat:
 Documentation/ia64/xen.txt         |  183 ++++++++++++++
 arch/ia64/Kconfig                  |   32 +++
 arch/ia64/Makefile                 |    2 +
 arch/ia64/kernel/acpi.c            |    5 +
 arch/ia64/kernel/asm-offsets.c     |   38 +++
 arch/ia64/kernel/nr-irqs.c         |    1 +
 arch/ia64/kernel/process.c         |    1 -
 arch/ia64/xen/Kconfig              |   26 ++
 arch/ia64/xen/Makefile             |   22 ++
 arch/ia64/xen/grant-table.c        |  155 ++++++++++++
 arch/ia64/xen/hypercall.S          |   91 +++++++
 arch/ia64/xen/hypervisor.c         |   96 ++++++++
 arch/ia64/xen/irq_xen.c            |  422 +++++++++++++++++++++++++++++++++
 arch/ia64/xen/irq_xen.h            |   34 +++
 arch/ia64/xen/machvec.c            |    4 +
 arch/ia64/xen/suspend.c            |   59 +++++
 arch/ia64/xen/time.c               |  198 +++++++++++++++
 arch/ia64/xen/time.h               |   24 ++
 arch/ia64/xen/xcom_hcall.c         |  441 ++++++++++++++++++++++++++++++++++
 arch/ia64/xen/xen_pv_ops.c         |  364 ++++++++++++++++++++++++++++
 arch/ia64/xen/xencomm.c            |  106 ++++++++
 arch/ia64/xen/xenivt.S             |   52 ++++
 arch/ia64/xen/xensetup.S           |   83 +++++++
 include/asm-ia64/machvec.h         |    2 +
 include/asm-ia64/machvec_xen.h     |   22 ++
 include/asm-ia64/meminit.h         |    3 +-
 include/asm-ia64/sync_bitops.h     |   57 +++++
 include/asm-ia64/timex.h           |    2 +
 include/asm-ia64/xen/events.h      |   50 ++++
 include/asm-ia64/xen/grant_table.h |   29 +++
 include/asm-ia64/xen/hypercall.h   |  265 +++++++++++++++++++++
 include/asm-ia64/xen/hypervisor.h  |   72 ++++++
 include/asm-ia64/xen/inst.h        |  461 ++++++++++++++++++++++++++++++++++++
 include/asm-ia64/xen/interface.h   |  320 +++++++++++++++++++++++++
 include/asm-ia64/xen/irq.h         |   44 ++++
 include/asm-ia64/xen/minstate.h    |  134 +++++++++++
 include/asm-ia64/xen/page.h        |   65 +++++
 include/asm-ia64/xen/privop.h      |  129 ++++++++++
 include/asm-ia64/xen/xcom_hcall.h  |   51 ++++
 include/asm-ia64/xen/xencomm.h     |   34 +++
 40 files changed, 4177 insertions(+), 2 deletions(-)
