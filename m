From: Jonathan Nieder <jrnieder@gmail.com>
Date: Wed, 16 May 2012 21:57:00 +0000
Subject: [PATCH 3.0.y, 3.2.y] ia64: Add accept4() syscall
Message-Id: <20120516215700.GA10476@burratino>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

From: Émeric Maschino <emeric.maschino@gmail.com>

commit 65cc21b4523e94d5640542a818748cd3be8cd6b4 upstream.

While debugging udev > 170 failure on Debian Wheezy
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bugd8325), it appears
that the issue was in fact due to missing accept4() in ia64.

This patch simply adds accept4() to ia64.

Signed-off-by: Émeric Maschino <emeric.maschino@gmail.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
Hi Ben and Greg,

Émeric Maschino wrote[1]:

> Starting with udev 170 (well, IIRC!), console is flooded at startup with:
>
>     udevd[XXX]: unable to receive ctrl connection: Function not implemented
>
> where XXX is a number (PID?).
>
> And system takes ~3 min. to get login prompt.

Indeed, udev versions since 168 (2011-04-22) require the accept4()
syscall.  That syscall was added to the kernel in 2.6.28 (2008-11-19),
but arches were slow to pick it up because checksyscalls.sh didn't
catch it[2] (it was implemented on 32-bit x86 using sys_socketcall).
Here is a list of when each arch added the syscall:

 x86 and arches using socketcall (2008-11-19) v2.6.28-rc6~45
 sparc64 (2008-11-19) v2.6.28-rc6~44
 MIPS (2009-08-03) v2.6.31-rc6~64^2
 microblaze (2009-12-28) v2.6.33-rc5~19^2~3
 sh64 (2010-01-19) v2.6.33-rc5~13^2
 parisc (2009-12-26) v2.6.34-rc1~13^2~6
 ARM (2010-08-15) v2.6.36-rc2~52^2~2
 sh (2010-12-13) v2.6.37-rc6~10^2
 alpha (2011-10-31) v3.2-rc1~108^2~58
 ia64 (2012-01-09) v3.3-rc1~73^2

Lots of arches are not listed above because they use the multiplexed
socketcall call and got support right away.  (sh and sh64 provide both
the direct syscall and socketcall.)

This patch was merged upstream during the 3.3 merge window and has
been in use in Debian's 3.2.y-based kernel since January.

As long as libc was built to use the syscall, applying this patch
makes udev work properly again on ia64.  What do you think?

Jonathan

[1] http://bugs.debian.org/648325
[2] http://thread.gmane.org/gmane.linux.kernel.cross-arch/11888/focus907

 arch/ia64/include/asm/unistd.h |    3 ++-
 arch/ia64/kernel/entry.S       |    3 +++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 7c928da35b17..d8de1825b736 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -321,11 +321,12 @@
 #define __NR_syncfs			1329
 #define __NR_setns			1330
 #define __NR_sendmmsg			1331
+#define __NR_accept4			1334
 
 #ifdef __KERNEL__
 
 
-#define NR_syscalls			308 /* length of syscall table */
+#define NR_syscalls			311 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 97dd2abdeb1a..df477f8c9d82 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1777,6 +1777,9 @@ sys_call_table:
 	data8 sys_syncfs
 	data8 sys_setns				// 1330
 	data8 sys_sendmmsg
+	data8 sys_ni_syscall	/* process_vm_readv */
+	data8 sys_ni_syscall	/* process_vm_writev */
+	data8 sys_accept4
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
-- 
1.7.10.2

