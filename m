From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 02 Mar 2017 00:46:07 +0000
Subject: [PATCH] uapi: fix another asm/shmbuf.h userspace compilation error
Message-Id: <20170302004607.GE27132@altlinux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org

Replace size_t with __kernel_size_t to fix asm/shmbuf.h userspace
compilation errors like this:

/usr/include/asm-generic/shmbuf.h:28:2: error: unknown type name 'size_t'
  size_t   shm_segsz; /* size of segment (bytes) */

x32 is the only architecture where sizeof(size_t) is less than
sizeof(__kernel_size_t), but as the kernel treats shm_segsz field as
__kernel_size_t anyway, UAPI should follow.  Thanks to little-endiannes
of x32 and 64-bit alignment of the field following shm_segsz, this
change doesn't break ABI, and the difference doesn't manifest itself
easily.

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/asm-generic/shmbuf.h      | 2 +-
 arch/alpha/include/uapi/asm/shmbuf.h   | 2 +-
 arch/avr32/include/uapi/asm/shmbuf.h   | 2 +-
 arch/frv/include/uapi/asm/shmbuf.h     | 2 +-
 arch/ia64/include/uapi/asm/shmbuf.h    | 2 +-
 arch/m32r/include/uapi/asm/shmbuf.h    | 2 +-
 arch/mips/include/uapi/asm/shmbuf.h    | 2 +-
 arch/mn10300/include/uapi/asm/shmbuf.h | 2 +-
 arch/powerpc/include/uapi/asm/shmbuf.h | 2 +-
 arch/s390/include/uapi/asm/shmbuf.h    | 2 +-
 arch/sparc/include/uapi/asm/shmbuf.h   | 2 +-
 arch/xtensa/include/uapi/asm/shmbuf.h  | 4 ++--
 12 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/uapi/asm-generic/shmbuf.h b/include/uapi/asm-generic/shmbuf.h
index 2a6d508..0756934 100644
--- a/include/uapi/asm-generic/shmbuf.h
+++ b/include/uapi/asm-generic/shmbuf.h
@@ -25,7 +25,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 #if __BITS_PER_LONG != 64
 	unsigned long		__unused1;
diff --git a/arch/alpha/include/uapi/asm/shmbuf.h b/arch/alpha/include/uapi/asm/shmbuf.h
index 6156099..e32ed1f 100644
--- a/arch/alpha/include/uapi/asm/shmbuf.h
+++ b/arch/alpha/include/uapi/asm/shmbuf.h
@@ -14,7 +14,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	__kernel_time_t		shm_dtime;	/* last detach time */
 	__kernel_time_t		shm_ctime;	/* last change time */
diff --git a/arch/avr32/include/uapi/asm/shmbuf.h b/arch/avr32/include/uapi/asm/shmbuf.h
index c8e5234..2804f25 100644
--- a/arch/avr32/include/uapi/asm/shmbuf.h
+++ b/arch/avr32/include/uapi/asm/shmbuf.h
@@ -15,7 +15,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
diff --git a/arch/frv/include/uapi/asm/shmbuf.h b/arch/frv/include/uapi/asm/shmbuf.h
index 943746c..2af199f 100644
--- a/arch/frv/include/uapi/asm/shmbuf.h
+++ b/arch/frv/include/uapi/asm/shmbuf.h
@@ -15,7 +15,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
diff --git a/arch/ia64/include/uapi/asm/shmbuf.h b/arch/ia64/include/uapi/asm/shmbuf.h
index ca81d77e..8e35495 100644
--- a/arch/ia64/include/uapi/asm/shmbuf.h
+++ b/arch/ia64/include/uapi/asm/shmbuf.h
@@ -14,7 +14,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	__kernel_time_t		shm_dtime;	/* last detach time */
 	__kernel_time_t		shm_ctime;	/* last change time */
diff --git a/arch/m32r/include/uapi/asm/shmbuf.h b/arch/m32r/include/uapi/asm/shmbuf.h
index 714de6e..fa36b9e 100644
--- a/arch/m32r/include/uapi/asm/shmbuf.h
+++ b/arch/m32r/include/uapi/asm/shmbuf.h
@@ -15,7 +15,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
diff --git a/arch/mips/include/uapi/asm/shmbuf.h b/arch/mips/include/uapi/asm/shmbuf.h
index f47d193..95c53ff 100644
--- a/arch/mips/include/uapi/asm/shmbuf.h
+++ b/arch/mips/include/uapi/asm/shmbuf.h
@@ -14,7 +14,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	__kernel_time_t		shm_dtime;	/* last detach time */
 	__kernel_time_t		shm_ctime;	/* last change time */
diff --git a/arch/mn10300/include/uapi/asm/shmbuf.h b/arch/mn10300/include/uapi/asm/shmbuf.h
index 71df684..e156878 100644
--- a/arch/mn10300/include/uapi/asm/shmbuf.h
+++ b/arch/mn10300/include/uapi/asm/shmbuf.h
@@ -15,7 +15,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
diff --git a/arch/powerpc/include/uapi/asm/shmbuf.h b/arch/powerpc/include/uapi/asm/shmbuf.h
index 7937289..a2425e5 100644
--- a/arch/powerpc/include/uapi/asm/shmbuf.h
+++ b/arch/powerpc/include/uapi/asm/shmbuf.h
@@ -38,7 +38,7 @@ struct shmid64_ds {
 #ifndef __powerpc64__
 	unsigned long		__unused4;
 #endif
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_pid_t		shm_cpid;	/* pid of creator */
 	__kernel_pid_t		shm_lpid;	/* pid of last operator */
 	unsigned long		shm_nattch;	/* no. of current attaches */
diff --git a/arch/s390/include/uapi/asm/shmbuf.h b/arch/s390/include/uapi/asm/shmbuf.h
index 9ce1d9f..9ddf9e0 100644
--- a/arch/s390/include/uapi/asm/shmbuf.h
+++ b/arch/s390/include/uapi/asm/shmbuf.h
@@ -15,7 +15,7 @@
 
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 #ifndef __s390x__
 	unsigned long		__unused1;
diff --git a/arch/sparc/include/uapi/asm/shmbuf.h b/arch/sparc/include/uapi/asm/shmbuf.h
index f651952..ed72656 100644
--- a/arch/sparc/include/uapi/asm/shmbuf.h
+++ b/arch/sparc/include/uapi/asm/shmbuf.h
@@ -27,7 +27,7 @@ struct shmid64_ds {
 	__kernel_time_t		shm_dtime;	/* last detach time */
 	PADDING(__pad3)
 	__kernel_time_t		shm_ctime;	/* last change time */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_pid_t		shm_cpid;	/* pid of creator */
 	__kernel_pid_t		shm_lpid;	/* pid of last operator */
 	unsigned long		shm_nattch;	/* no. of current attaches */
diff --git a/arch/xtensa/include/uapi/asm/shmbuf.h b/arch/xtensa/include/uapi/asm/shmbuf.h
index ad90d05..8d9206e 100644
--- a/arch/xtensa/include/uapi/asm/shmbuf.h
+++ b/arch/xtensa/include/uapi/asm/shmbuf.h
@@ -24,7 +24,7 @@
 #if defined (__XTENSA_EL__)
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
@@ -40,7 +40,7 @@ struct shmid64_ds {
 #elif defined (__XTENSA_EB__)
 struct shmid64_ds {
 	struct ipc64_perm	shm_perm;	/* operation perms */
-	size_t			shm_segsz;	/* size of segment (bytes) */
+	__kernel_size_t		shm_segsz;	/* size of segment (bytes) */
 	__kernel_time_t		shm_atime;	/* last attach time */
 	unsigned long		__unused1;
 	__kernel_time_t		shm_dtime;	/* last detach time */
-- 
ldv
