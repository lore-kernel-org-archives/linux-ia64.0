From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 18 Sep 2002 03:25:06 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.32)
Message-Id: <marc-linux-ia64-105590701906036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a patch.  The problem was the struct initialisers change in
other files --- they meant that the INIT_THREAD_IA32 macro didn't line
up properly with the things it was meant to initialise.

--- /tmp/geta19551	2002-09-18 13:18:27.000000000 +1000
+++ linux-2.5-ia64/include/asm-ia64/processor.h	2002-09-18 13:14:55.000000000 +1000
@@ -236,7 +236,7 @@
 	__u64 ssd;			/* IA32 stack selector descriptor */
 	__u64 old_k1;			/* old value of ar.k1 */
 	__u64 old_iob;			/* old IOBase value */
-# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0,
+# define INIT_THREAD_IA32	.eflag = 0, .fsr = 0, .fcr = 0x17800000037fULL, .fir = 0, .fdr = 0, .csd = 0, .ssd = 0, .old_k1 = 0, .old_iob = 0,
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
@@ -248,7 +248,7 @@
 	atomic_t pfm_notifiers_check;	/* when >0, will cleanup ctx_notify_task in tasklist */
 	atomic_t pfm_owners_check;	/* when >0, will cleanup ctx_owner in tasklist */
 	void *pfm_smpl_buf_list;	/* list of sampling buffers to vfree */
-# define INIT_THREAD_PM		{0, }, {0, }, 0, NULL, {0}, {0}, NULL,
+# define INIT_THREAD_PM		.pmc = {0, }, .pmd = {0, }, .pfm_ovfl_block_reset = 0, .pfm_context = NULL, .pfm_notifiers_check = {0}, .pfm_owners_check = {0}, .pfm_smpl_buf_list = NULL,
 #else
 # define INIT_THREAD_PM
 #endif
@@ -258,16 +258,16 @@
 };
 
 #define INIT_THREAD {				\
-	flags:		0,			\
-	ksp:		0,			\
-	map_base:	DEFAULT_MAP_BASE,	\
-	task_size:	DEFAULT_TASK_SIZE,	\
-	siginfo:	0,			\
+	.flags=		0,			\
+	.ksp=		0,			\
+	.map_base=	DEFAULT_MAP_BASE,	\
+	.task_size=	DEFAULT_TASK_SIZE,	\
+	.siginfo=	0,			\
 	INIT_THREAD_IA32			\
 	INIT_THREAD_PM				\
-	dbr:		{0, },			\
-	ibr:		{0, },			\
-	fph:		{{{{0}}}, }		\
+	.dbr=		{0, },			\
+	.ibr=		{0, },			\
+	.fph=		{{{{0}}}, }		\
 }
 
 #define start_thread(regs,new_ip,new_sp) do {							\

