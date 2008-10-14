From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 14 Oct 2008 05:51:15 +0000
Subject: [PATCH 00/32] ia64/xen domU take 11
Message-Id: <1223963507-28056-1-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patchset is ia64/xen domU patch take 11.
Tony, please commit those patches.
They are ready to commit because all the issues which were pointed out
had been addressed and got enough reviews.


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


For convenience the working full source is available from
http://people.valinux.co.jp/~yamahata/xen-ia64/for_eagl/linux-2.6-ia64-pv-ops.git/
branch: ia64-pv-ops-2008oct14-xen-ia64

For the status of this patch series
http://wiki.xensource.com/xenwiki/XenIA64/UpstreamMerge

At this phase, we don't address the following issues.
Those will be addressed after the first merge.
- optimization by binary patch
  In fact, we had the patch to do that, but we intentionally dropped
  for patch size/readability/cleanness.
- freeing the unused pages, i.e. pages for unused ivt.S.
- complete save/restore support
- ar.itc paravirtualization which is necessary for save/restore support

Changes from take 10:
- rebased to 2.6.27
- renamed pv_iosapic_ops::get_irq_chip to pv_iosapic_ops::__get_irq_chip.
- improved SSM_PSR_I to detect invalid register usage.
- fixed consider_steal_time() of pv_time_ops.

Changes from take 9:
- rebased to 2.6.27-rc4
- caught up for moving header files.
- caught up for x86 xen changes (mainly xen mode predicate)
- enhanced pv checker to detect inappropriate register usage.
- typo

Changes from take 8:
- rebased to 2.6.26
- updated pvclock-abi.h

Changes from take 7:
- various typos
- clean up sync_bitops.h
- style fix on include/asm-ia64/xen/interface.h
- reserve the "break" numbers in include/asm-ia64/break.h
- xencomm clean up
- dropped NET_SKB_PAD patch. It was a bug in xen-netfront.c.
- CONFIG_IA64_XEN -> CONFIG_IA64_XEN_GUEST
- catch up for x86 pvclock-abi.h
- work around for IPI with IA64_TIME_VECTOR
- add pv checker

Changes from take 6:
- rebased to linux ia64 test tree
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
 Documentation/ia64/xen.txt                |  183 +++++++++++
 arch/ia64/Kconfig                         |   32 ++
 arch/ia64/Makefile                        |    2 
 arch/ia64/include/asm/break.h             |    9 
 arch/ia64/include/asm/machvec.h           |    2 
 arch/ia64/include/asm/machvec_xen.h       |   22 +
 arch/ia64/include/asm/meminit.h           |    3 
 arch/ia64/include/asm/native/inst.h       |   10 
 arch/ia64/include/asm/native/pvchk_inst.h |  263 +++++++++++++++++
 arch/ia64/include/asm/paravirt.h          |    4 
 arch/ia64/include/asm/pvclock-abi.h       |    5 
 arch/ia64/include/asm/sync_bitops.h       |   51 +++
 arch/ia64/include/asm/timex.h             |    2 
 arch/ia64/include/asm/xen/events.h        |   50 +++
 arch/ia64/include/asm/xen/grant_table.h   |   29 +
 arch/ia64/include/asm/xen/hypercall.h     |  265 +++++++++++++++++
 arch/ia64/include/asm/xen/hypervisor.h    |   89 +++++
 arch/ia64/include/asm/xen/inst.h          |  458 ++++++++++++++++++++++++++++++
 arch/ia64/include/asm/xen/interface.h     |  346 ++++++++++++++++++++++
 arch/ia64/include/asm/xen/irq.h           |   44 ++
 arch/ia64/include/asm/xen/minstate.h      |  134 ++++++++
 arch/ia64/include/asm/xen/page.h          |   65 ++++
 arch/ia64/include/asm/xen/privop.h        |  129 ++++++++
 arch/ia64/include/asm/xen/xcom_hcall.h    |   51 +++
 arch/ia64/include/asm/xen/xencomm.h       |   42 ++
 arch/ia64/kernel/Makefile                 |   18 +
 arch/ia64/kernel/acpi.c                   |    5 
 arch/ia64/kernel/asm-offsets.c            |   31 ++
 arch/ia64/kernel/nr-irqs.c                |    1 
 arch/ia64/kernel/paravirt.c               |    2 
 arch/ia64/kernel/paravirt_inst.h          |    4 
 arch/ia64/kernel/process.c                |    1 
 arch/ia64/scripts/pvcheck.sed             |   32 ++
 arch/ia64/xen/Kconfig                     |   26 +
 arch/ia64/xen/Makefile                    |   42 ++
 arch/ia64/xen/grant-table.c               |  155 ++++++++++
 arch/ia64/xen/hypercall.S                 |   91 +++++
 arch/ia64/xen/hypervisor.c                |   96 ++++++
 arch/ia64/xen/irq_xen.c                   |  435 ++++++++++++++++++++++++++++
 arch/ia64/xen/irq_xen.h                   |   34 ++
 arch/ia64/xen/machvec.c                   |    4 
 arch/ia64/xen/suspend.c                   |   45 ++
 arch/ia64/xen/time.c                      |  213 +++++++++++++
 arch/ia64/xen/time.h                      |   24 +
 arch/ia64/xen/xcom_hcall.c                |  441 ++++++++++++++++++++++++++++
 arch/ia64/xen/xen_pv_ops.c                |  364 +++++++++++++++++++++++
 arch/ia64/xen/xencomm.c                   |  105 ++++++
 arch/ia64/xen/xenivt.S                    |   52 +++
 arch/ia64/xen/xensetup.S                  |   83 +++++
 49 files changed, 4574 insertions(+), 20 deletions(-)

