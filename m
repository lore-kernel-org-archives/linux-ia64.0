From: Bob Montgomery <bob.montgomery@hp.com>
Date: Tue, 10 Feb 2004 00:48:57 +0000
Subject: unwabi mismatch in 2.4.X kernels breaks oops call trace (unwind)
Message-Id: <1076374136.10372.3.camel@peas.bobm>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops stack unwinding was broken in 2.4.22 by this patch that was
picked up from 2.5/2.6:
                               
--- 1.5/arch/ia64/kernel/entry.h	Mon Feb  9 13:41:40 2004
+++ 1.6/arch/ia64/kernel/entry.h	Mon Feb  9 13:41:40 2004
@@ -14,7 +14,7 @@
 #define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET)
 
 #define PT_REGS_SAVES(off)			\
-	.unwabi @svr4, 'i';			\
+	.unwabi 3, 'i';				\
 	.fframe IA64_PT_REGS_SIZE+16+(off);	\
 	.spillsp rp, PT(CR_IIP)+16+(off);	\
 	.spillsp ar.pfs, PT(CR_IFS)+16+(off);	\


If we want to keep this change in 2.4.X, we need to also change the
test in desc_abi (unwind.c) to check for abi = 3 instead of 0.

static inline void
desc_abi (unsigned char abi, unsigned char context, struct unw_state_record *sr){
        if (abi = 0 && context = 'i') {
                sr->flags |= UNW_FLAG_INTERRUPT_FRAME;
                UNW_DPRINT(3, "unwind.%s: interrupt frame\n", __FUNCTION__);
        }
        else
                UNW_DPRINT(0, "unwind%s: ignoring unwabi(abi=0x%x,context=0x%x)\n",
                                __FUNCTION__, abi, context);
}

Otherwise we can just back the entry.h patch out.  So my question
is: Is there a compelling reason to change the abi number from 0 to
3 in 2.4.X kernels?  Is there an outside tool that cares, or is it
sufficient for these two snippets of kernel code to merely agree on
some number?

Thanks,
Bob Montgomery


