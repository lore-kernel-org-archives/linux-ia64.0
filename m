From: Christian Kandeler <christian.kandeler@hob.de>
Date: Mon, 09 Jul 2007 14:13:02 +0000
Subject: [PATCH] Stop bit for brl instruction
Message-Id: <200707091613.02091.christian.kandeler@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

this issue has already been discussed (see 
http://marc.info/?t7768963900017&r=1&w=2) and I was under the 
impression that it would be resolved in 2.6.2.22. Since it's not, I'm 
submitting this small patch.

Signed-off-by: Christian Kandeler <christian.kandeler@hob.de>

--- arch/ia64/kernel/gate.S.orig        2007-07-09 15:18:58.000000000 
+0200
+++ arch/ia64/kernel/gate.S     2007-07-09 15:23:03.000000000 +0200
@@ -30,6 +30,7 @@
        .previous
 #define BRL_COND_FSYS_BUBBLE_DOWN(pr)			\
 [1:](pr)brl.cond.sptk 0;				\
+	;;						\
 	.xdata4 ".data.patch.brl_fsys_bubble_down", 1b-.

 GLOBAL_ENTRY(__kernel_syscall_via_break)
