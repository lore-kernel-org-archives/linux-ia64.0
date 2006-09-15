From: Horms <horms@verge.net.au>
Date: Fri, 15 Sep 2006 01:48:37 +0000
Subject: [PATCH] [IA64] kdump: kdump_disable_iosapic needs CONFIG_KEXEC
Message-Id: <20060915014837.GA21649@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060915014422.GA21437@verge.net.au>
In-Reply-To: <20060915014422.GA21437@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Nanhai,

Currently kdump_disable_iosapic is gaurded by CONFIG_CRASH_DUMP,
however it is run buy the crashing kernel, not the crash kernel,
and thus needs to be present for CONFIG_KEXEC, not CONFIG_CRASH_DUMP.

Signed-Off-By: Simon Horman <horms@verge.net.au>

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 9e9367a..2f58502 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -288,7 +288,7 @@ nop (unsigned int irq)
 	/* do nothing... */
 }
 
-#ifdef CONFIG_CRASH_DUMP
+#ifdef CONFIG_KEXEC
 void
 kdump_disable_iosapic(void)
 {
