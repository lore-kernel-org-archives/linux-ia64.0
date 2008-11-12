From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 Nov 2008 01:35:50 +0000
Subject: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some kernels report a few unaligned exceptions during early userspace:

init(1): unaligned access to 0x6000000000089f0b, ip=0x40000000000e3581
init(1): unaligned access to 0x6000000000089f13, ip=0x40000000000e3620
init(1): unaligned access to 0x6000000000089f11, ip=0x40000000000e3640
init(1): unaligned access to 0x600000000008af1b, ip=0x40000000000e3581
init(1): unaligned access to 0x600000000008af23, ip=0x40000000000e3620
fsck(3193): unaligned access to 0x600000000001255b, ip=0x2000000000069491
fsck(3193): unaligned access to 0x6000000000012563, ip=0x2000000000069530
fsck(3193): unaligned access to 0x6000000000012561, ip=0x2000000000069550
mount(3205): unaligned access to 0x6000000000012c2b, ip=0x2000000000069491
mount(3205): unaligned access to 0x6000000000012c33, ip=0x2000000000069530
mount(3855): unaligned access to 0x6000000000012c6b, ip=0x2000000000069491
mount(3855): unaligned access to 0x6000000000012c73, ip=0x2000000000069530
mount(3855): unaligned access to 0x6000000000012c71, ip=0x2000000000069550

while others do not report these exceptions. A git bisection pointed
at an apparently innocent commit.  The real problem is that we do
not explicitly set or clear PSR.ac (we do clear it when executing
32-bit x86 binaries) so it is randomly set or clear in different
kernel builds.

Fix is to clear PSR.ac before transitioning to user code.


Signed-off-by: Tony Luck <tony.luck@intel.com>

---

Does the use of "rum" instruction need some paravirtualization? It is
not in a critical path (used a couple of times during boot).

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 7ef0c59..595a0b6 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -499,6 +499,7 @@ GLOBAL_ENTRY(prefetch_stack)
 END(prefetch_stack)
 
 GLOBAL_ENTRY(kernel_execve)
+	rum IA64_PSR_AC
 	mov r15=__NR_execve			// put syscall number in place
 	break __BREAK_SYSCALL
 	br.ret.sptk.many rp
