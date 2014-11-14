From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 15:18:19 +0000
Subject: [PATCH 02/11] mpx: extend siginfo structure to include bound violation information
Message-Id: <20141114151819.1908C900@viggo.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141114151816.F56A3072@viggo.jf.intel.com>
In-Reply-To: <20141114151816.F56A3072@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


This patch adds new fields about bound violation into siginfo
structure. si_lower and si_upper are respectively lower bound
and upper bound when bound violation is caused.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/include/uapi/asm-generic/siginfo.h |    9 ++++++++-
 b/kernel/signal.c                    |    4 ++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff -puN include/uapi/asm-generic/siginfo.h~mpx-v11-mpx-extend-siginfo-structure-to-include-bound-violation-information include/uapi/asm-generic/siginfo.h
--- a/include/uapi/asm-generic/siginfo.h~mpx-v11-mpx-extend-siginfo-structure-to-include-bound-violation-information	2014-11-14 07:06:21.148558419 -0800
+++ b/include/uapi/asm-generic/siginfo.h	2014-11-14 07:06:21.153558645 -0800
@@ -91,6 +91,10 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb; /* LSB of the reported address */
+			struct {
+				void __user *_lower;
+				void __user *_upper;
+			} _addr_bnd;
 		} _sigfault;
 
 		/* SIGPOLL */
@@ -131,6 +135,8 @@ typedef struct siginfo {
 #define si_trapno	_sifields._sigfault._trapno
 #endif
 #define si_addr_lsb	_sifields._sigfault._addr_lsb
+#define si_lower	_sifields._sigfault._addr_bnd._lower
+#define si_upper	_sifields._sigfault._addr_bnd._upper
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
 #ifdef __ARCH_SIGSYS
@@ -199,7 +205,8 @@ typedef struct siginfo {
  */
 #define SEGV_MAPERR	(__SI_FAULT|1)	/* address not mapped to object */
 #define SEGV_ACCERR	(__SI_FAULT|2)	/* invalid permissions for mapped object */
-#define NSIGSEGV	2
+#define SEGV_BNDERR	(__SI_FAULT|3)  /* failed address bound checks */
+#define NSIGSEGV	3
 
 /*
  * SIGBUS si_codes
diff -puN kernel/signal.c~mpx-v11-mpx-extend-siginfo-structure-to-include-bound-violation-information kernel/signal.c
--- a/kernel/signal.c~mpx-v11-mpx-extend-siginfo-structure-to-include-bound-violation-information	2014-11-14 07:06:21.150558509 -0800
+++ b/kernel/signal.c	2014-11-14 07:06:21.155558734 -0800
@@ -2748,6 +2748,10 @@ int copy_siginfo_to_user(siginfo_t __use
 		if (from->si_code = BUS_MCEERR_AR || from->si_code = BUS_MCEERR_AO)
 			err |= __put_user(from->si_addr_lsb, &to->si_addr_lsb);
 #endif
+#ifdef SEGV_BNDERR
+		err |= __put_user(from->si_lower, &to->si_lower);
+		err |= __put_user(from->si_upper, &to->si_upper);
+#endif
 		break;
 	case __SI_CHLD:
 		err |= __put_user(from->si_pid, &to->si_pid);
_
