From: Dave Hansen <dave@sr71.net>
Date: Fri, 14 Nov 2014 15:18:20 +0000
Subject: [PATCH 03/11] mips: sync struct siginfo with general version
Message-Id: <20141114151820.F7EDC3CC@viggo.jf.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20141114151816.F56A3072@viggo.jf.intel.com>
In-Reply-To: <20141114151816.F56A3072@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hpa@zytor.com
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


New fields about bound violation are added into general struct
siginfo. This will impact MIPS and IA64, which extend general
struct siginfo. This patch syncs this struct for MIPS with
general version.

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/mips/include/uapi/asm/siginfo.h |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN arch/mips/include/uapi/asm/siginfo.h~mpx-v11-mips-sync-struct-siginfo-with-general-version arch/mips/include/uapi/asm/siginfo.h
--- a/arch/mips/include/uapi/asm/siginfo.h~mpx-v11-mips-sync-struct-siginfo-with-general-version	2014-11-14 07:06:21.551576596 -0800
+++ b/arch/mips/include/uapi/asm/siginfo.h	2014-11-14 07:06:21.554576731 -0800
@@ -92,6 +92,10 @@ typedef struct siginfo {
 			int _trapno;	/* TRAP # which caused the signal */
 #endif
 			short _addr_lsb;
+			struct {
+				void __user *_lower;
+				void __user *_upper;
+			} _addr_bnd;
 		} _sigfault;
 
 		/* SIGPOLL, SIGXFSZ (To do ...)	 */
_
