From: =?UTF-8?q?Christian=20G=C3=B6ttsche?= <cgzones@googlemail.com>
Date: Tue, 30 Aug 2022 15:28:38 +0000
Subject: [RFC PATCH 2/2] fs/xattr: wire up syscalls
Message-Id: <20220830152858.14866-1-cgzones@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: selinux@vger.kernel.org
Cc: Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, =?UTF-8?q?Andr=C3=A9=20Almeida?= <andrealmeid@igalia.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Guo Ren <guoren@kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Wang Haojun <jiangliuer01@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org, linux-audit@redhat.com, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

Enable the new added extended attribute related syscalls.

Signed-off-by: Christian G=C3=B6ttsche <cgzones@googlemail.com>
---
TODO:
  - deprecate traditional syscalls (setxattr, ...)?
  - resolve possible conflicts with proposed readfile syscall
---
 arch/alpha/kernel/syscalls/syscall.tbl      |  4 ++++
 arch/arm/tools/syscall.tbl                  |  4 ++++
 arch/arm64/include/asm/unistd.h             |  2 +-
 arch/arm64/include/asm/unistd32.h           |  8 ++++++++
 arch/ia64/kernel/syscalls/syscall.tbl       |  4 ++++
 arch/m68k/kernel/syscalls/syscall.tbl       |  4 ++++
 arch/microblaze/kernel/syscalls/syscall.tbl |  4 ++++
 arch/mips/kernel/syscalls/syscall_n32.tbl   |  4 ++++
 arch/mips/kernel/syscalls/syscall_n64.tbl   |  4 ++++
 arch/mips/kernel/syscalls/syscall_o32.tbl   |  4 ++++
 arch/parisc/kernel/syscalls/syscall.tbl     |  4 ++++
 arch/powerpc/kernel/syscalls/syscall.tbl    |  4 ++++
 arch/s390/kernel/syscalls/syscall.tbl       |  4 ++++
 arch/sh/kernel/syscalls/syscall.tbl         |  4 ++++
 arch/sparc/kernel/syscalls/syscall.tbl      |  4 ++++
 arch/x86/entry/syscalls/syscall_32.tbl      |  4 ++++
 arch/x86/entry/syscalls/syscall_64.tbl      |  4 ++++
 arch/xtensa/kernel/syscalls/syscall.tbl     |  4 ++++
 include/asm-generic/audit_change_attr.h     |  6 ++++++
 include/linux/syscalls.h                    |  8 ++++++++
 include/uapi/asm-generic/unistd.h           | 12 +++++++++++-
 21 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/kernel/syscalls/syscall.tbl b/arch/alpha/kernel/sys=
calls/syscall.tbl
index 3515bc4f16a4..826a8a36da81 100644
--- a/arch/alpha/kernel/syscalls/syscall.tbl
+++ b/arch/alpha/kernel/syscalls/syscall.tbl
@@ -490,3 +490,7 @@
 558	common	process_mrelease		sys_process_mrelease
 559	common  futex_waitv                     sys_futex_waitv
 560	common	set_mempolicy_home_node		sys_ni_syscall
+561	common	setxattrat			sys_setxattrat
+562	common	getxattrat			sys_getxattrat
+563	common	listxattrat			sys_listxattrat
+564	common	removexattrat			sys_removexattrat
diff --git a/arch/arm/tools/syscall.tbl b/arch/arm/tools/syscall.tbl
index ac964612d8b0..f0e9d9d487f0 100644
--- a/arch/arm/tools/syscall.tbl
+++ b/arch/arm/tools/syscall.tbl
@@ -464,3 +464,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common	futex_waitv			sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/arm64/include/asm/unistd.h b/arch/arm64/include/asm/unist=
d.h
index 037feba03a51..63a8a9c4abc1 100644
--- a/arch/arm64/include/asm/unistd.h
+++ b/arch/arm64/include/asm/unistd.h
@@ -39,7 +39,7 @@
 #define __ARM_NR_compat_set_tls		(__ARM_NR_COMPAT_BASE + 5)
 #define __ARM_NR_COMPAT_END		(__ARM_NR_COMPAT_BASE + 0x800)
=20
-#define __NR_compat_syscalls		451
+#define __NR_compat_syscalls		455
 #endif
=20
 #define __ARCH_WANT_SYS_CLONE
diff --git a/arch/arm64/include/asm/unistd32.h b/arch/arm64/include/asm/uni=
std32.h
index 604a2053d006..cd6ac63376d1 100644
--- a/arch/arm64/include/asm/unistd32.h
+++ b/arch/arm64/include/asm/unistd32.h
@@ -907,6 +907,14 @@ __SYSCALL(__NR_process_mrelease, sys_process_mrelease)
 __SYSCALL(__NR_futex_waitv, sys_futex_waitv)
 #define __NR_set_mempolicy_home_node 450
 __SYSCALL(__NR_set_mempolicy_home_node, sys_set_mempolicy_home_node)
+#define __NR_setxattrat 451
+__SYSCALL(__NR_setxattrat, sys_setxattrat)
+#define __NR_getxattrat 452
+__SYSCALL(__NR_getxattrat, sys_getxattrat)
+#define __NR_listxattrat 453
+__SYSCALL(__NR_listxattrat, sys_listxattrat)
+#define __NR_removexattrat 454
+__SYSCALL(__NR_removexattrat, sys_removexattrat)
=20
 /*
  * Please add new compat syscalls above this comment and update
diff --git a/arch/ia64/kernel/syscalls/syscall.tbl b/arch/ia64/kernel/sysca=
lls/syscall.tbl
index 78b1d03e86e1..6e942a935a27 100644
--- a/arch/ia64/kernel/syscalls/syscall.tbl
+++ b/arch/ia64/kernel/syscalls/syscall.tbl
@@ -371,3 +371,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/m68k/kernel/syscalls/syscall.tbl b/arch/m68k/kernel/sysca=
lls/syscall.tbl
index b1f3940bc298..0847efdee734 100644
--- a/arch/m68k/kernel/syscalls/syscall.tbl
+++ b/arch/m68k/kernel/syscalls/syscall.tbl
@@ -450,3 +450,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/microblaze/kernel/syscalls/syscall.tbl b/arch/microblaze/=
kernel/syscalls/syscall.tbl
index 820145e47350..7f619bbc718d 100644
--- a/arch/microblaze/kernel/syscalls/syscall.tbl
+++ b/arch/microblaze/kernel/syscalls/syscall.tbl
@@ -456,3 +456,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/mips/kernel/syscalls/syscall_n32.tbl b/arch/mips/kernel/s=
yscalls/syscall_n32.tbl
index 253ff994ed2e..5e4206c0aede 100644
--- a/arch/mips/kernel/syscalls/syscall_n32.tbl
+++ b/arch/mips/kernel/syscalls/syscall_n32.tbl
@@ -389,3 +389,7 @@
 448	n32	process_mrelease		sys_process_mrelease
 449	n32	futex_waitv			sys_futex_waitv
 450	n32	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	n32	setxattrat			sys_setxattrat
+452	n32	getxattrat			sys_getxattrat
+453	n32	listxattrat			sys_listxattrat
+454	n32	removexattrat			sys_removexattrat
diff --git a/arch/mips/kernel/syscalls/syscall_n64.tbl b/arch/mips/kernel/s=
yscalls/syscall_n64.tbl
index 3f1886ad9d80..df0f053e76cd 100644
--- a/arch/mips/kernel/syscalls/syscall_n64.tbl
+++ b/arch/mips/kernel/syscalls/syscall_n64.tbl
@@ -365,3 +365,7 @@
 448	n64	process_mrelease		sys_process_mrelease
 449	n64	futex_waitv			sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	n64	setxattrat			sys_setxattrat
+452	n64	getxattrat			sys_getxattrat
+453	n64	listxattrat			sys_listxattrat
+454	n64	removexattrat			sys_removexattrat
diff --git a/arch/mips/kernel/syscalls/syscall_o32.tbl b/arch/mips/kernel/s=
yscalls/syscall_o32.tbl
index 8f243e35a7b2..09ec31ad475f 100644
--- a/arch/mips/kernel/syscalls/syscall_o32.tbl
+++ b/arch/mips/kernel/syscalls/syscall_o32.tbl
@@ -438,3 +438,7 @@
 448	o32	process_mrelease		sys_process_mrelease
 449	o32	futex_waitv			sys_futex_waitv
 450	o32	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	o32	setxattrat			sys_setxattrat
+452	o32	getxattrat			sys_getxattrat
+453	o32	listxattrat			sys_listxattrat
+454	o32	removexattrat			sys_removexattrat
diff --git a/arch/parisc/kernel/syscalls/syscall.tbl b/arch/parisc/kernel/s=
yscalls/syscall.tbl
index 8a99c998da9b..fe3f4f41aee6 100644
--- a/arch/parisc/kernel/syscalls/syscall.tbl
+++ b/arch/parisc/kernel/syscalls/syscall.tbl
@@ -448,3 +448,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common	futex_waitv			sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/powerpc/kernel/syscalls/syscall.tbl b/arch/powerpc/kernel=
/syscalls/syscall.tbl
index 2600b4237292..bee27f650397 100644
--- a/arch/powerpc/kernel/syscalls/syscall.tbl
+++ b/arch/powerpc/kernel/syscalls/syscall.tbl
@@ -530,3 +530,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450 	nospu	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/s390/kernel/syscalls/syscall.tbl b/arch/s390/kernel/sysca=
lls/syscall.tbl
index 799147658dee..d1fbad4b7864 100644
--- a/arch/s390/kernel/syscalls/syscall.tbl
+++ b/arch/s390/kernel/syscalls/syscall.tbl
@@ -453,3 +453,7 @@
 448  common	process_mrelease	sys_process_mrelease		sys_process_mrelease
 449  common	futex_waitv		sys_futex_waitv			sys_futex_waitv
 450  common	set_mempolicy_home_node	sys_set_mempolicy_home_node	sys_set_me=
mpolicy_home_node
+451  common	setxattrat		sys_setxattrat			sys_setxattrat
+452  common	getxattrat		sys_getxattrat			sys_getxattrat
+453  common	listxattrat		sys_listxattrat			sys_listxattrat
+454  common	removexattrat		sys_removexattrat		sys_removexattrat
diff --git a/arch/sh/kernel/syscalls/syscall.tbl b/arch/sh/kernel/syscalls/=
syscall.tbl
index 2de85c977f54..d4daa8afe45c 100644
--- a/arch/sh/kernel/syscalls/syscall.tbl
+++ b/arch/sh/kernel/syscalls/syscall.tbl
@@ -453,3 +453,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/sparc/kernel/syscalls/syscall.tbl b/arch/sparc/kernel/sys=
calls/syscall.tbl
index 4398cc6fb68d..510d5175f80a 100644
--- a/arch/sparc/kernel/syscalls/syscall.tbl
+++ b/arch/sparc/kernel/syscalls/syscall.tbl
@@ -496,3 +496,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscal=
ls/syscall_32.tbl
index 320480a8db4f..8488cc157fe0 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -455,3 +455,7 @@
 448	i386	process_mrelease	sys_process_mrelease
 449	i386	futex_waitv		sys_futex_waitv
 450	i386	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	i386	setxattrat		sys_setxattrat
+452	i386	getxattrat		sys_getxattrat
+453	i386	listxattrat		sys_listxattrat
+454	i386	removexattrat		sys_removexattrat
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscal=
ls/syscall_64.tbl
index c84d12608cd2..f45d723d5a30 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -372,6 +372,10 @@
 448	common	process_mrelease	sys_process_mrelease
 449	common	futex_waitv		sys_futex_waitv
 450	common	set_mempolicy_home_node	sys_set_mempolicy_home_node
+451	common	setxattrat		sys_setxattrat
+452	common	getxattrat		sys_getxattrat
+453	common	listxattrat		sys_listxattrat
+454	common	removexattrat		sys_removexattrat
=20
 #
 # Due to a historical design error, certain syscalls are numbered differen=
tly
diff --git a/arch/xtensa/kernel/syscalls/syscall.tbl b/arch/xtensa/kernel/s=
yscalls/syscall.tbl
index 52c94ab5c205..dbafe441a83f 100644
--- a/arch/xtensa/kernel/syscalls/syscall.tbl
+++ b/arch/xtensa/kernel/syscalls/syscall.tbl
@@ -421,3 +421,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450	common	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/include/asm-generic/audit_change_attr.h b/include/asm-generic/=
audit_change_attr.h
index 331670807cf0..cc840537885f 100644
--- a/include/asm-generic/audit_change_attr.h
+++ b/include/asm-generic/audit_change_attr.h
@@ -11,9 +11,15 @@ __NR_lchown,
 __NR_fchown,
 #endif
 __NR_setxattr,
+#ifdef __NR_setxattrat
+__NR_setxattrat,
+#endif
 __NR_lsetxattr,
 __NR_fsetxattr,
 __NR_removexattr,
+#ifdef __NR_removexattrat
+__NR_removexattrat,
+#endif
 __NR_lremovexattr,
 __NR_fremovexattr,
 #ifdef __NR_fchownat
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a34b0f9a9972..090b9b5229a0 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -348,23 +348,31 @@ asmlinkage long sys_io_uring_register(unsigned int fd=
, unsigned int op,
 /* fs/xattr.c */
 asmlinkage long sys_setxattr(const char __user *path, const char __user *n=
ame,
 			     const void __user *value, size_t size, int flags);
+asmlinkage long sys_setxattrat(int dfd, const char __user *path, const cha=
r __user *name,
+			     const void __user *value, size_t size, int flags);
 asmlinkage long sys_lsetxattr(const char __user *path, const char __user *=
name,
 			      const void __user *value, size_t size, int flags);
 asmlinkage long sys_fsetxattr(int fd, const char __user *name,
 			      const void __user *value, size_t size, int flags);
 asmlinkage long sys_getxattr(const char __user *path, const char __user *n=
ame,
 			     void __user *value, size_t size);
+asmlinkage long sys_getxattrat(int dfd, const char __user *path, const cha=
r __user *name,
+			     void __user *value, size_t size, int flags);
 asmlinkage long sys_lgetxattr(const char __user *path, const char __user *=
name,
 			      void __user *value, size_t size);
 asmlinkage long sys_fgetxattr(int fd, const char __user *name,
 			      void __user *value, size_t size);
 asmlinkage long sys_listxattr(const char __user *path, char __user *list,
 			      size_t size);
+asmlinkage long sys_listxattrat(int dfd, const char __user *path, char __u=
ser *list,
+			      size_t size, int flags);
 asmlinkage long sys_llistxattr(const char __user *path, char __user *list,
 			       size_t size);
 asmlinkage long sys_flistxattr(int fd, char __user *list, size_t size);
 asmlinkage long sys_removexattr(const char __user *path,
 				const char __user *name);
+asmlinkage long sys_removexattrat(int dfd, const char __user *path,
+				const char __user *name, int flags);
 asmlinkage long sys_lremovexattr(const char __user *path,
 				 const char __user *name);
 asmlinkage long sys_fremovexattr(int fd, const char __user *name);
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/u=
nistd.h
index 45fa180cc56a..4fcc71612b7a 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -886,8 +886,18 @@ __SYSCALL(__NR_futex_waitv, sys_futex_waitv)
 #define __NR_set_mempolicy_home_node 450
 __SYSCALL(__NR_set_mempolicy_home_node, sys_set_mempolicy_home_node)
=20
+/* fs/xattr.c */
+#define __NR_setxattrat 451
+__SYSCALL(__NR_setxattrat, sys_setxattrat)
+#define __NR_getxattrat 452
+__SYSCALL(__NR_getxattrat, sys_getxattrat)
+#define __NR_listxattrat 453
+__SYSCALL(__NR_listxattrat, sys_listxattrat)
+#define __NR_removexattrat 454
+__SYSCALL(__NR_removexattrat, sys_removexattrat)
+
 #undef __NR_syscalls
-#define __NR_syscalls 451
+#define __NR_syscalls 455
=20
 /*
  * 32 bit systems traditionally used different
--=20
2.37.2
