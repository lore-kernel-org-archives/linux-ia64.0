From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Feb 2004 20:43:10 +0000
Subject: Re: unwabi mismatch in 2.4.X kernels breaks oops call trace (unwind)
Message-Id: <200402101343.10070.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1076374136.10372.3.camel@peas.bobm>
In-Reply-To: <1076374136.10372.3.camel@peas.bobm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 09 February 2004 6:28 pm, David Mosberger wrote:
> >>>>> On Mon, 09 Feb 2004 17:48:57 -0700, Bob Montgomery <bob.montgomery@hp.com> said:
> 
>   Bob> So my question is: Is there a compelling reason to change the
>   Bob> abi number from 0 to 3 in 2.4.X kernels?
> 
> It must change iff the syscall-streamlining patch is applied, since
> that patch changes the format of the pt-regs structure.

In 2.4, we have this patch:

	ia64: Restructure pt_regs and optimize syscall path.

	Patch by Rohit Seth, Fengua Yu, and Arun Sharma:

	The main items covered by this patch are:
	1) Support for 16 bytes instructions as per SDM2.1 (CSD/SSD in pt_regs)
	2) f10-f11 are added as additional scratch registers for kernel's use.
	3) Re-arrange pt_regs to access less cache lines in system call. Reduce
	scratch register saving/restoring in system call path.
	4) A few instruction reorg in low-level code.

(See this link for details: http://lia64.bkbits.net:8080/linux-ia64-2.4/cset@1.1019.9.3)

So I assume the right thing to do is to apply the following patch to 2.4.
I'll do this later today unless anybody objects.

=== arch/ia64/kernel/unwind.c 1.27 vs edited ==--- 1.27/arch/ia64/kernel/unwind.c	Thu Aug 14 11:26:15 2003
+++ edited/arch/ia64/kernel/unwind.c	Tue Feb 10 13:41:51 2004
@@ -826,7 +826,7 @@
 static inline void
 desc_abi (unsigned char abi, unsigned char context, struct unw_state_record *sr)
 {
-	if (abi = 0 && context = 'i') {
+	if (abi = 3 && context = 'i') {
 		sr->flags |= UNW_FLAG_INTERRUPT_FRAME;
 		UNW_DPRINT(3, "unwind.%s: interrupt frame\n",  __FUNCTION__);
 	}

