From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 30 Jul 2003 22:13:34 +0000
Subject: Re: Kenerl Entry/Exit optimization patch for your bk tree
Message-Id: <marc-linux-ia64-105960328604158@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 10 June 2003 3:26 pm, Seth, Rohit wrote:
> Please find attached the Kernel entry/exit patch against your latest
> 2.4.20-bk tree.  This is derived from (now settled) 2.5 kernel patch
> that David has in his tree.  One major change from 2.5 is that
> ia64_execve still has the same old hack to support IA-32 apps (that is
> currently broken on 2.5).
> 
> This patch also has the support for 16-bytes instructions that are
> mentioned in SDM2.1  

I applied this patch to the 2.4 tree, with the following edit:

diff -Nru a/arch/ia64/kernel/entry.h b/arch/ia64/kernel/entry.h
--- a/arch/ia64/kernel/entry.h  Wed Jul 30 16:51:44 2003
+++ b/arch/ia64/kernel/entry.h  Wed Jul 30 16:51:44 2003
@@ -14,7 +14,7 @@
 #define SW(f)          (IA64_SWITCH_STACK_##f##_OFFSET)
 
 #define PT_REGS_SAVES(off)                     \
-       .unwabi @svr4, 'i';                     \
+       .unwabi 3, 'i';                         \
        .fframe IA64_PT_REGS_SIZE+16+(off);     \
        .spillsp rp, PT(CR_IIP)+16+(off);       \
        .spillsp ar.pfs, PT(CR_IFS)+16+(off);   \

