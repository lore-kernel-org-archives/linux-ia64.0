From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:15 +0000
Subject: [PATCH 00/50] ia64/xen take 3: ia64/xen domU paravirtualization
Message-Id: <12047411453864-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. This patchset implements xen/ia64 domU support.
Qing He and Eddie Dong also has been woring on pv_ops so that
I want to discuss before going further and avoid duplicated work.
I suppose that Eddie will also post his own patch. So reviewing both
patches, we can reach to better pv_ops interface.


- I didn't changed the ia64 intrinsic paravirtulization abi from
  the last post. Presumably it would be better to discuss with
  the Eddie's patch.

- I implemented The basic portion of domU pv_ops.
  They may need the interface refinement. Probably Eddie has
  his own opinion.

- This time I dropped the patches which hasn't been pv_ops'fied yet 
  because they aren't changed from the last post.

You can also get the full source from
http://people.valinux.co.jp/~yamahata/xen-ia64/linux-2.6-xen-ia64.git/
branch: xen-ia64-2008mar06

The patchset are organized as follows
- xen arch portability.
  Generalizes x86 xen patches for ia64 support.
- some preliminary patches.
  Make kernel paravirtualization friendly.
- introduce pv_ops and the definitions for native.
- basic helper functions for xen ia64 support.
- introduce the pv_ops instance for xen/ia64.


TODO:
- discuss and define intrinsic paravirtualization abi.
- discuss pv_ops.
- more pv_ops for domU
  - mca/sal call
  - timer
  - gate page
  - fsys
- support save/restore/live migration
- more clean ups
  - remove unnecessary if (is_running_on_xen()).
- Free xen_ivt areas somehow. No waste kernel space
  From Keith Owens idea.
  Probably after defining ABI because this is just optimization.
- dom0
  consider after finishing domU/ia64 merge.


Changes from take 2:
- many clean ups following to comments.
- clean up:assembly instruction macro.
- introduced pv_ops: pv_info, pv_init_ops, pv_iosapic_ops, pv_irq_ops.

Changes from take 1:
Single IVT source code. compile multitimes using assembler macros.

thanks,

Diffstat:
 arch/ia64/Kconfig                                  |   72 +++
 arch/ia64/kernel/Makefile                          |   30 +-
 arch/ia64/kernel/acpi.c                            |    4 +
 arch/ia64/kernel/asm-offsets.c                     |   25 +
 arch/ia64/kernel/entry.S                           |  568 +------------------
 arch/ia64/kernel/head.S                            |    6 +
 arch/ia64/kernel/inst_native.h                     |  183 ++++++
 arch/ia64/kernel/inst_paravirt.h                   |   28 +
 arch/ia64/kernel/iosapic.c                         |   43 +-
 arch/ia64/kernel/irq_ia64.c                        |   21 +-
 arch/ia64/kernel/ivt.S                             |  153 +++---
 arch/ia64/kernel/minstate.h                        |   10 +-
 arch/ia64/kernel/module.c                          |   32 +
 arch/ia64/kernel/pal.S                             |    5 +-
 arch/ia64/kernel/paravirt.c                        |   94 +++
 arch/ia64/kernel/paravirt_alt.c                    |  118 ++++
 arch/ia64/kernel/paravirt_core.c                   |  201 +++++++
 arch/ia64/kernel/paravirt_entry.c                  |   99 ++++
 arch/ia64/kernel/paravirt_nop.c                    |   49 ++
 arch/ia64/kernel/paravirtentry.S                   |   37 ++
 arch/ia64/kernel/setup.c                           |   14 +
 arch/ia64/kernel/smpboot.c                         |    2 +
 arch/ia64/kernel/switch_leave.S                    |  603 +++++++++++++++++++
 arch/ia64/kernel/vmlinux.lds.S                     |   35 ++
 arch/ia64/xen/Makefile                             |    9 +
 arch/ia64/xen/hypercall.S                          |  141 +++++
 arch/ia64/xen/hypervisor.c                         |  235 ++++++++
 arch/ia64/xen/inst_xen.h                           |  503 ++++++++++++++++
 arch/ia64/xen/irq_xen.c                            |  435 ++++++++++++++
 arch/ia64/xen/irq_xen.h                            |    8 +
 arch/ia64/xen/machvec.c                            |    4 +
 arch/ia64/xen/paravirt_xen.c                       |  242 ++++++++
 arch/ia64/xen/privops_asm.S                        |  221 +++++++
 arch/ia64/xen/privops_c.c                          |  279 +++++++++
 arch/ia64/xen/util.c                               |  101 ++++
 arch/ia64/xen/xcom_asm.S                           |   27 +
 arch/ia64/xen/xcom_hcall.c                         |  458 +++++++++++++++
 arch/ia64/xen/xen_pv_ops.c                         |  319 ++++++++++
 arch/ia64/xen/xencomm.c                            |  108 ++++
 arch/ia64/xen/xenivt.S                             |   59 ++
 arch/ia64/{kernel/minstate.h => xen/xenminstate.h} |   96 +---
 arch/ia64/xen/xenpal.S                             |   76 +++
 arch/ia64/xen/xensetup.S                           |   60 ++
 arch/x86/xen/Makefile                              |    4 +-
 arch/x86/xen/grant-table.c                         |   91 +++
 arch/x86/xen/xen-ops.h                             |    2 +-
 drivers/xen/Makefile                               |    3 +-
 {arch/x86 => drivers}/xen/events.c                 |   33 +-
 {arch/x86 => drivers}/xen/features.c               |    0 
 drivers/xen/grant-table.c                          |   37 +--
 drivers/xen/xenbus/xenbus_client.c                 |    6 +-
 drivers/xen/xencomm.c                              |  232 ++++++++
 include/asm-ia64/gcc_intrin.h                      |   58 +-
 include/asm-ia64/hw_irq.h                          |   24 +-
 include/asm-ia64/intel_intrin.h                    |   64 +-
 include/asm-ia64/intrinsics.h                      |   12 +
 include/asm-ia64/iosapic.h                         |   18 +-
 include/asm-ia64/irq.h                             |   33 ++
 include/asm-ia64/machvec.h                         |    2 +
 include/asm-ia64/machvec_xen.h                     |   22 +
 include/asm-ia64/meminit.h                         |    3 +-
 include/asm-ia64/mmu_context.h                     |    6 +-
 include/asm-ia64/module.h                          |    6 +
 include/asm-ia64/page.h                            |    8 +
 include/asm-ia64/paravirt.h                        |  284 +++++++++
 include/asm-ia64/paravirt_alt.h                    |   82 +++
 include/asm-ia64/paravirt_core.h                   |   54 ++
 include/asm-ia64/paravirt_entry.h                  |   62 ++
 include/asm-ia64/paravirt_nop.h                    |   46 ++
 include/asm-ia64/privop.h                          |   67 +++
 include/asm-ia64/privop_paravirt.h                 |  587 +++++++++++++++++++
 include/asm-ia64/sync_bitops.h                     |   59 ++
 include/asm-ia64/system.h                          |    4 +-
 include/asm-ia64/xen/hypercall.h                   |  426 ++++++++++++++
 include/asm-ia64/xen/hypervisor.h                  |  249 ++++++++
 include/asm-ia64/xen/interface.h                   |  585 +++++++++++++++++++
 include/asm-ia64/xen/page.h                        |   41 ++
 include/asm-ia64/xen/privop.h                      |  609 ++++++++++++++++++++
 include/asm-ia64/xen/xcom_hcall.h                  |   55 ++
 include/asm-ia64/xen/xencomm.h                     |   33 ++
 include/asm-x86/xen/hypervisor.h                   |   10 +
 include/asm-x86/xen/interface.h                    |   24 +
 include/{ => asm-x86}/xen/page.h                   |    0 
 include/xen/events.h                               |    1 +
 include/xen/grant_table.h                          |    6 +
 include/xen/interface/callback.h                   |  119 ++++
 include/xen/interface/grant_table.h                |   11 +-
 include/xen/interface/vcpu.h                       |    5 +
 include/xen/interface/xen.h                        |   22 +-
 include/xen/interface/xencomm.h                    |   41 ++
 include/xen/page.h                                 |  181 +------
 include/xen/xen-ops.h                              |    6 +
 include/xen/xencomm.h                              |   77 +++
 93 files changed, 9174 insertions(+), 1049 deletions(-)
