From: =?UTF-8?q?Christian=20G=C3=B6ttsche?= <cgzones@googlemail.com>
Date: Thu, 11 May 2023 15:08:02 +0000
Subject: [RFC PATCH v2] fs/xattr: add *at family syscalls
Message-Id: <20230511150802.737477-1-cgzones@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: 
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, audit@vger.kernel.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org

Add the four syscalls setxattrat(), getxattrat(), listxattrat() and
removexattrat().  Those can be used to operate on extended attributes,
especially security related ones, either relative to a pinned directory
or on a file descriptor without read access, avoiding a
/proc/<pid>/fd/<fd> detour, requiring a mounted procfs.

One use case will be setfiles(8) setting SELinux file contexts
("security.selinux") without race conditions.

Add XATTR flags to the private namespace of AT_* flags.

Use the do_{name}at() pattern from fs/open.c.

Use a single flag parameter for extended attribute flags (currently
XATTR_CREATE and XATTR_REPLACE) and *at() flags to not exceed six
syscall arguments in setxattrat().

Previous approach ("f*xattr: allow O_PATH descriptors"): https://lore.kerne=
l.org/all/20220607153139.35588-1-cgzones@googlemail.com/
v1 discussion: https://lore.kernel.org/all/20220830152858.14866-2-cgzones@g=
ooglemail.com/

Signed-off-by: Christian G=C3=B6ttsche <cgzones@googlemail.com>
CC: x86@kernel.org
CC: linux-alpha@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-arm-kernel@lists.infradead.org
CC: linux-ia64@vger.kernel.org
CC: linux-m68k@lists.linux-m68k.org
CC: linux-mips@vger.kernel.org
CC: linux-parisc@vger.kernel.org
CC: linuxppc-dev@lists.ozlabs.org
CC: linux-s390@vger.kernel.org
CC: linux-sh@vger.kernel.org
CC: sparclinux@vger.kernel.org
CC: linux-fsdevel@vger.kernel.org
CC: audit@vger.kernel.org
CC: linux-arch@vger.kernel.org
CC: linux-api@vger.kernel.org
CC: linux-security-module@vger.kernel.org
CC: selinux@vger.kernel.org
---
v2:
  - squash syscall introduction and wire up commits
  - add AT_XATTR_CREATE and AT_XATTR_REPLACE constants
---
 arch/alpha/kernel/syscalls/syscall.tbl      |   4 +
 arch/arm/tools/syscall.tbl                  |   4 +
 arch/arm64/include/asm/unistd.h             |   2 +-
 arch/arm64/include/asm/unistd32.h           |   8 ++
 arch/ia64/kernel/syscalls/syscall.tbl       |   4 +
 arch/m68k/kernel/syscalls/syscall.tbl       |   4 +
 arch/microblaze/kernel/syscalls/syscall.tbl |   4 +
 arch/mips/kernel/syscalls/syscall_n32.tbl   |   4 +
 arch/mips/kernel/syscalls/syscall_n64.tbl   |   4 +
 arch/mips/kernel/syscalls/syscall_o32.tbl   |   4 +
 arch/parisc/kernel/syscalls/syscall.tbl     |   4 +
 arch/powerpc/kernel/syscalls/syscall.tbl    |   4 +
 arch/s390/kernel/syscalls/syscall.tbl       |   4 +
 arch/sh/kernel/syscalls/syscall.tbl         |   4 +
 arch/sparc/kernel/syscalls/syscall.tbl      |   4 +
 arch/x86/entry/syscalls/syscall_32.tbl      |   4 +
 arch/x86/entry/syscalls/syscall_64.tbl      |   4 +
 arch/xtensa/kernel/syscalls/syscall.tbl     |   4 +
 fs/xattr.c                                  | 107 ++++++++++++++++----
 include/asm-generic/audit_change_attr.h     |   6 ++
 include/linux/syscalls.h                    |   8 ++
 include/uapi/asm-generic/unistd.h           |  12 ++-
 include/uapi/linux/fcntl.h                  |   2 +
 23 files changed, 185 insertions(+), 24 deletions(-)

diff --git a/arch/alpha/kernel/syscalls/syscall.tbl b/arch/alpha/kernel/sys=
calls/syscall.tbl
index 8ebacf37a8cf..1dc58a5dc730 100644
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
index 72c929d9902b..fe9aea54222c 100644
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
index 0e42fceb2d5e..0123f895a674 100644
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
index a0be127475b1..06fd4153f0d1 100644
--- a/arch/powerpc/kernel/syscalls/syscall.tbl
+++ b/arch/powerpc/kernel/syscalls/syscall.tbl
@@ -537,3 +537,7 @@
 448	common	process_mrelease		sys_process_mrelease
 449	common  futex_waitv                     sys_futex_waitv
 450 	nospu	set_mempolicy_home_node		sys_set_mempolicy_home_node
+451	common	setxattrat			sys_setxattrat
+452	common	getxattrat			sys_getxattrat
+453	common	listxattrat			sys_listxattrat
+454	common	removexattrat			sys_removexattrat
diff --git a/arch/s390/kernel/syscalls/syscall.tbl b/arch/s390/kernel/sysca=
lls/syscall.tbl
index b68f47541169..9babd831fe1e 100644
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
diff --git a/fs/xattr.c b/fs/xattr.c
index fcf67d80d7f9..a57ce39483d7 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -656,21 +656,34 @@ setxattr(struct mnt_idmap *idmap, struct dentry *d,
 	return error;
 }
=20
-static int path_setxattr(const char __user *pathname,
+static int do_setxattrat(int dfd, const char __user *pathname,
 			 const char __user *name, const void __user *value,
-			 size_t size, int flags, unsigned int lookup_flags)
+			 size_t size, int flags)
 {
 	struct path path;
 	int error;
+	int lookup_flags;
=20
+	/* AT_ and XATTR_ flags must not overlap. */
+	BUILD_BUG_ON(XATTR_CREATE !=3D AT_XATTR_CREATE);
+	BUILD_BUG_ON(XATTR_REPLACE !=3D AT_XATTR_REPLACE);
+	#define AT_XATTR__FLAGS (AT_XATTR_CREATE | AT_XATTR_REPLACE)
+	BUILD_BUG_ON(((AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH) & AT_XATTR__FLAGS) !=
=3D 0);
+
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH | AT_XATTR__FLAGS)) !=
=3D 0)
+		return -EINVAL;
+
+	lookup_flags =3D (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	if (flags & AT_EMPTY_PATH)
+		lookup_flags |=3D LOOKUP_EMPTY;
 retry:
-	error =3D user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+	error =3D user_path_at(dfd, pathname, lookup_flags, &path);
 	if (error)
 		return error;
 	error =3D mnt_want_write(path.mnt);
 	if (!error) {
 		error =3D setxattr(mnt_idmap(path.mnt), path.dentry, name,
-				 value, size, flags);
+				 value, size, flags & AT_XATTR__FLAGS);
 		mnt_drop_write(path.mnt);
 	}
 	path_put(&path);
@@ -681,18 +694,25 @@ static int path_setxattr(const char __user *pathname,
 	return error;
 }
=20
+SYSCALL_DEFINE6(setxattrat, int, dfd, const char __user *, pathname,
+		const char __user *, name, const void __user *, value,
+		size_t, size, int, flags)
+{
+	return do_setxattrat(dfd, pathname, name, value, size, flags);
+}
+
 SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
 		const char __user *, name, const void __user *, value,
 		size_t, size, int, flags)
 {
-	return path_setxattr(pathname, name, value, size, flags, LOOKUP_FOLLOW);
+	return do_setxattrat(AT_FDCWD, pathname, name, value, size, flags);
 }
=20
 SYSCALL_DEFINE5(lsetxattr, const char __user *, pathname,
 		const char __user *, name, const void __user *, value,
 		size_t, size, int, flags)
 {
-	return path_setxattr(pathname, name, value, size, flags, 0);
+	return do_setxattrat(AT_FDCWD, pathname, name, value, size, flags | AT_SY=
MLINK_NOFOLLOW);
 }
=20
 SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
@@ -775,14 +795,22 @@ getxattr(struct mnt_idmap *idmap, struct dentry *d,
 	return error;
 }
=20
-static ssize_t path_getxattr(const char __user *pathname,
+static ssize_t do_getxattrat(int dfd, const char __user *pathname,
 			     const char __user *name, void __user *value,
-			     size_t size, unsigned int lookup_flags)
+			     size_t size, int flags)
 {
 	struct path path;
 	ssize_t error;
+	int lookup_flags;
+
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) !=3D 0)
+		return -EINVAL;
+
+	lookup_flags =3D (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	if (flags & AT_EMPTY_PATH)
+		lookup_flags |=3D LOOKUP_EMPTY;
 retry:
-	error =3D user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+	error =3D user_path_at(dfd, pathname, lookup_flags, &path);
 	if (error)
 		return error;
 	error =3D getxattr(mnt_idmap(path.mnt), path.dentry, name, value, size);
@@ -794,16 +822,23 @@ static ssize_t path_getxattr(const char __user *pathn=
ame,
 	return error;
 }
=20
+SYSCALL_DEFINE6(getxattrat, int, dfd, const char __user *, pathname,
+		const char __user *, name, void __user *, value, size_t, size,
+		int, flags)
+{
+	return do_getxattrat(dfd, pathname, name, value, size, flags);
+}
+
 SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
 		const char __user *, name, void __user *, value, size_t, size)
 {
-	return path_getxattr(pathname, name, value, size, LOOKUP_FOLLOW);
+	return do_getxattrat(AT_FDCWD, pathname, name, value, size, 0);
 }
=20
 SYSCALL_DEFINE4(lgetxattr, const char __user *, pathname,
 		const char __user *, name, void __user *, value, size_t, size)
 {
-	return path_getxattr(pathname, name, value, size, 0);
+	return do_getxattrat(AT_FDCWD, pathname, name, value, size, AT_SYMLINK_NO=
FOLLOW);
 }
=20
 SYSCALL_DEFINE4(fgetxattr, int, fd, const char __user *, name,
@@ -853,13 +888,21 @@ listxattr(struct dentry *d, char __user *list, size_t=
 size)
 	return error;
 }
=20
-static ssize_t path_listxattr(const char __user *pathname, char __user *li=
st,
-			      size_t size, unsigned int lookup_flags)
+static ssize_t do_listxattrat(int dfd, const char __user *pathname, char _=
_user *list,
+			      size_t size, int flags)
 {
 	struct path path;
 	ssize_t error;
+	int lookup_flags;
+
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) !=3D 0)
+		return -EINVAL;
+
+	lookup_flags =3D (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	if (flags & AT_EMPTY_PATH)
+		lookup_flags |=3D LOOKUP_EMPTY;
 retry:
-	error =3D user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+	error =3D user_path_at(dfd, pathname, lookup_flags, &path);
 	if (error)
 		return error;
 	error =3D listxattr(path.dentry, list, size);
@@ -871,16 +914,22 @@ static ssize_t path_listxattr(const char __user *path=
name, char __user *list,
 	return error;
 }
=20
+SYSCALL_DEFINE5(listxattrat, int, dfd, const char __user *, pathname, char=
 __user *, list,
+		size_t, size, int, flags)
+{
+	return do_listxattrat(dfd, pathname, list, size, flags);
+}
+
 SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, l=
ist,
 		size_t, size)
 {
-	return path_listxattr(pathname, list, size, LOOKUP_FOLLOW);
+	return do_listxattrat(AT_FDCWD, pathname, list, size, 0);
 }
=20
 SYSCALL_DEFINE3(llistxattr, const char __user *, pathname, char __user *, =
list,
 		size_t, size)
 {
-	return path_listxattr(pathname, list, size, 0);
+	return do_listxattrat(AT_FDCWD, pathname, list, size, AT_SYMLINK_NOFOLLOW=
);
 }
=20
 SYSCALL_DEFINE3(flistxattr, int, fd, char __user *, list, size_t, size)
@@ -899,7 +948,7 @@ SYSCALL_DEFINE3(flistxattr, int, fd, char __user *, lis=
t, size_t, size)
 /*
  * Extended attribute REMOVE operations
  */
-static long
+static int
 removexattr(struct mnt_idmap *idmap, struct dentry *d,
 	    const char __user *name)
 {
@@ -918,13 +967,21 @@ removexattr(struct mnt_idmap *idmap, struct dentry *d,
 	return vfs_removexattr(idmap, d, kname);
 }
=20
-static int path_removexattr(const char __user *pathname,
-			    const char __user *name, unsigned int lookup_flags)
+static int do_removexattrat(int dfd, const char __user *pathname,
+			    const char __user *name, int flags)
 {
 	struct path path;
 	int error;
+	int lookup_flags;
+
+	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) !=3D 0)
+		return -EINVAL;
+
+	lookup_flags =3D (flags & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
+	if (flags & AT_EMPTY_PATH)
+		lookup_flags |=3D LOOKUP_EMPTY;
 retry:
-	error =3D user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+	error =3D user_path_at(dfd, pathname, lookup_flags, &path);
 	if (error)
 		return error;
 	error =3D mnt_want_write(path.mnt);
@@ -940,16 +997,22 @@ static int path_removexattr(const char __user *pathna=
me,
 	return error;
 }
=20
+SYSCALL_DEFINE4(removexattrat, int, dfd, const char __user *, pathname,
+		const char __user *, name, int, flags)
+{
+	return do_removexattrat(dfd, pathname, name, flags);
+}
+
 SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
 		const char __user *, name)
 {
-	return path_removexattr(pathname, name, LOOKUP_FOLLOW);
+	return do_removexattrat(AT_FDCWD, pathname, name, 0);
 }
=20
 SYSCALL_DEFINE2(lremovexattr, const char __user *, pathname,
 		const char __user *, name)
 {
-	return path_removexattr(pathname, name, 0);
+	return do_removexattrat(AT_FDCWD, pathname, name, AT_SYMLINK_NOFOLLOW);
 }
=20
 SYSCALL_DEFINE2(fremovexattr, int, fd, const char __user *, name)
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
index 33a0ee3bcb2e..0612661c9eca 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -350,23 +350,31 @@ asmlinkage long sys_io_uring_register(unsigned int fd=
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
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index e8c07da58c9f..b456547c8460 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -96,6 +96,8 @@
 #define AT_FDCWD		-100    /* Special value used to indicate
                                            openat should use the current
                                            working directory. */
+#define AT_XATTR_CREATE	        0x1	/* setxattrat(2): set value, fail if a=
ttr already exists */
+#define AT_XATTR_REPLACE	0x2	/* setxattrat(2): set value, fail if attr doe=
s not exist */
 #define AT_SYMLINK_NOFOLLOW	0x100   /* Do not follow symbolic links.  */
 #define AT_EACCESS		0x200	/* Test access permitted for
                                            effective IDs, not real IDs.  */
--=20
2.40.1
