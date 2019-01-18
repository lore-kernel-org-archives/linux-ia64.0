From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Jan 2019 16:18:13 +0000
Subject: [PATCH v2 07/29] ARM: add kexec_file_load system call number
Message-Id: <20190118161835.2259170-8-arnd@arndb.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190118161835.2259170-1-arnd@arndb.de>
In-Reply-To: <20190118161835.2259170-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, jcmvbkbc@gmail.com, deepa.kernel@gmail.com, hpa@zytor.com, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, mpe@ellerman.id.au, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, mingo@redhat.com, geert@linux-m68k.org, benh@kernel.crashing.org, firoz.khan@linaro.org, mattst88@gmail.com, fenghua.yu@intel.com, Arnd Bergmann <arnd@arndb.de>, heiko.carstens@de.ibm.com, linux-fsdevel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, luto@kernel.org, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tony.luck@intel.com, linux-parisc@vger.kernel.org, netdev@vger.kernel.org, linux-mips@vger.kernel.org, paul.burton@mips.com, ebiederm@xmission.com, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, akpm@linux-foundation.orglinu

A couple of architectures including arm64 already implement the
kexec_file_load system call, on many others we have assigned a system
call number for it, but not implemented it yet.

Adding the number in arch/arm/ lets us use the system call on arm64
systems in compat mode, and also reduces the number of differences
between architectures. If we want to implement kexec_file_load on ARM
in the future, the number assignment means that kexec tools can already
be built with the now current set of kernel headers.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/tools/syscall.tbl        | 1 +
 arch/arm64/include/asm/unistd.h   | 2 +-
 arch/arm64/include/asm/unistd32.h | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/arm/tools/syscall.tbl b/arch/arm/tools/syscall.tbl
index 86de9eb34296..20ed7e026723 100644
--- a/arch/arm/tools/syscall.tbl
+++ b/arch/arm/tools/syscall.tbl
@@ -415,3 +415,4 @@
 398	common	rseq			sys_rseq
 399	common	io_pgetevents		sys_io_pgetevents
 400	common	migrate_pages		sys_migrate_pages
+401	common	kexec_file_load		sys_kexec_file_load
diff --git a/arch/arm64/include/asm/unistd.h b/arch/arm64/include/asm/unistd.h
index 261216c3336e..2c30e6f145ff 100644
--- a/arch/arm64/include/asm/unistd.h
+++ b/arch/arm64/include/asm/unistd.h
@@ -44,7 +44,7 @@
 #define __ARM_NR_compat_set_tls		(__ARM_NR_COMPAT_BASE + 5)
 #define __ARM_NR_COMPAT_END		(__ARM_NR_COMPAT_BASE + 0x800)
 
-#define __NR_compat_syscalls		401
+#define __NR_compat_syscalls		402
 #endif
 
 #define __ARCH_WANT_SYS_CLONE
diff --git a/arch/arm64/include/asm/unistd32.h b/arch/arm64/include/asm/unistd32.h
index f15bcbacb8f6..8ca1d4c304f4 100644
--- a/arch/arm64/include/asm/unistd32.h
+++ b/arch/arm64/include/asm/unistd32.h
@@ -823,6 +823,8 @@ __SYSCALL(__NR_rseq, sys_rseq)
 __SYSCALL(__NR_io_pgetevents, compat_sys_io_pgetevents)
 #define __NR_migrate_pages 400
 __SYSCALL(__NR_migrate_pages, compat_sys_migrate_pages)
+#define __NR_kexec_file_load 401
+__SYSCALL(__NR_kexec_file_load, sys_kexec_file_load)
 
 /*
  * Please add new compat syscalls above this comment and update
-- 
2.20.0
