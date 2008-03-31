From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 08:23:34 +0000
Subject: [Patch][00/17] kvm-ia64 for kernel V8
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104823B@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This version included the review comments from community.  Thanks for
your feedback!  :-)
The whole git repo is located at
git://git.kernel.org/pub/scm/linux/kernel/git/xiantao/kvm-ia64.git
kvm-ia64-mc8. 


 Documentation/ia64/kvm-howto.txt |   71 +
 arch/ia64/Kconfig                |    6 
 arch/ia64/Makefile               |    1 
 arch/ia64/kernel/mca.c           |   50 
 arch/ia64/kernel/mca_asm.S       |    5 
 arch/ia64/kernel/smp.c           |   84 +
 arch/ia64/kvm/Kconfig            |   43 
 arch/ia64/kvm/Makefile           |   61 +
 arch/ia64/kvm/asm-offsets.c      |  251 ++++
 arch/ia64/kvm/ia64_regs.h        |  234 ++++
 arch/ia64/kvm/kvm_fw.c           |  500 +++++++++
 arch/ia64/kvm/kvm_ia64.c         | 1789
++++++++++++++++++++++++++++++++
 arch/ia64/kvm/kvm_minstate.h     |  273 ++++
 arch/ia64/kvm/lapic.h            |   27 
 arch/ia64/kvm/misc.h             |   93 +
 arch/ia64/kvm/mmio.c             |  349 ++++++
 arch/ia64/kvm/optvfault.S        |  918 ++++++++++++++++
 arch/ia64/kvm/process.c          |  979 +++++++++++++++++
 arch/ia64/kvm/trampoline.S       | 1040 ++++++++++++++++++
 arch/ia64/kvm/vcpu.c             | 2145
+++++++++++++++++++++++++++++++++++++++
 arch/ia64/kvm/vcpu.h             |  749 +++++++++++++
 arch/ia64/kvm/vmm.c              |   66 +
 arch/ia64/kvm/vmm_ivt.S          | 1425 +++++++++++++++++++++++++
 arch/ia64/kvm/vti.h              |  290 +++++
 arch/ia64/kvm/vtlb.c             |  631 +++++++++++
 arch/ia64/mm/tlb.c               |  170 +++
 include/asm-ia64/kregs.h         |    3 
 include/asm-ia64/kvm.h           |  205 +++
 include/asm-ia64/kvm_host.h      |  530 +++++++++
 include/asm-ia64/kvm_para.h      |   29 
 include/asm-ia64/tlb.h           |   12 
 include/linux/smp.h              |    3 
 32 files changed, 13014 insertions(+), 18 deletions(-)

 



