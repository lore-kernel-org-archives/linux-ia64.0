From: n0ano@indstorage.com
Date: Sun, 14 Oct 2001 18:35:54 +0000
Subject: Re: [Linux-ia64] Probable seamless bug: can't pop es
MIME-Version: 1
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Message-Id: <marc-linux-ia64-105590698805341@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805337@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805337@msgid-missing>
To: linux-ia64@vger.kernel.org

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii

Short answer:  Yes, the GDTD was set up wrong, here's the patch to
fix this.  (I must be getting better, it only took me a weekend to
find the single bit that had to change rather than my typical effort
of over a week :-)  We were neglecting to set the present bit, an
obvious no-no.

Long answer:  I'm amazed we've gotten as far as we have with this
bug.  ANY attempt by an IA32 program to load a segment register from
the GDT would cause a fault.  The only reason we have worked up to
now is that the IA64 code sets up all of the segment descriptors
manually without reference to the GDT and very few protected mode
IA32 programs attempt to load any of the segment registers.

Also, there is a non-zero change that this will fix the problem with
Wine trying to run certain programs, you might want to try TurboTax
again with this fix in.

On Thu, Oct 11, 2001 at 06:11:23PM -0700, David Mosberger wrote:
> >>>>> On Thu, 11 Oct 2001 17:19:32 -0700, "Robboy, David G" <david.g.robboy@intel.com> said:
> 
>   David.R> The following simple program runs on a P4 linux system, but
>   David.R> gets a SIGSEGV on an Itanium.  Most likely a seamless bug
>   David.R> rather than a hardware bug.  Even though we don't use
>   David.R> segment registers in Linux, it is legal to push and pop
>   David.R> them, isn't it?
> 
> Actually, even segmentation is supported (via modify_ldt()), so the
> program should work.  GDB says it dies on the "popl" instruction.  The
> address that triggering the fault is 0x4c.  I don't see where this is
> coming from.  My suspicion is that the segv happens when the CPU
> attempts to load the segment descriptor from the GDT, but if that's
> the case, the address should be somewhere in the 0xc0000000 range.
> Another possibility is that the GDTD is not set up properly, but I
> don't see anything obvious that's wrong there.
> 
> Perhaps someone more familiar with x86 could take a look?
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch-ia64-1024.p"

--- kernel-bigsur-ref/arch/ia64/ia32/binfmt_elf32.c	Tue Sep 25 19:40:29 2001
+++ kernel-bigsur/arch/ia64/ia32/binfmt_elf32.c	Sun Oct 14 10:36:59 2001
@@ -135,10 +135,11 @@
 	/*
 	 * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descriptor
 	 * format defined by Figure 3-11 "Pseudo-Descriptor Format" in the IA-32
-	 * architecture manual.
+	 * architecture manual.  Also note that the only fields that are not
+	 * ignored are `base', `limit', 'G', `P' (must be 1) and `S' (must be 0)
 	 */
-	regs->r31 = IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA32_PAGE_SIZE - 1, 0,
-							    0, 0, 0, 0, 0, 0));
+	regs->r31 = IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET,
+			IA32_PAGE_SIZE - 1, 0, 0, 0, 1, 0, 0, 0));
 
 	ia64_psr(regs)->ac = 0;		/* turn off alignment checking */
 	regs->loadrs = 0;

--X1bOJ3K7DJ5YkBrT--

