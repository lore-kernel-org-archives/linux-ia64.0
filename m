From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Mon, 07 Apr 2008 09:47:38 +0000
Subject: pv_ops progress & ask for suggestion
Message-Id: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony & all:
	Recently we have completed the IVT.s pv_ops by using dual
compile, and also many cleanups to simplify the changes to upstream
code. All the C code touching privilege instruction is replaced with
indirect function call (will be binary patched to use direct function
call in future), and IVT table is dual compiled to minimize impact to
native IVT table, but we get some dilemma in handling kernel/entry.S and
also generic policy for other ASM files.

	In entry.S, there are around 17 privilege instructions, some of
them must be paravirtualized including 2 cover instructions, and 1 "RFI"
(this one is due to Xen hypervisor issue). There are other 15 privilege
instructions (In Xen) such as CR access that could be paravirtualized
for performance reason.

	Now we have 2 choices:
	Alt1:  Dual compile entry.S like IVT.s (dual compile all ASM
files if it needs virtualization)
		pros: Same policy with iVT, use same MACRO to
replacement.
		cons: There are other ASM files such as
sn/kernel/pio_phys.S need to be dual compiled too.
			And unlike IVT table, the memory occupied by
dual compiled code won't be able to be freed easily since the size is
not fixed. Also all future ASM code touch privilege instruction may need
to be dual compiled too.

	Alt2: Use indirect call like C code for non IVT nor gate page
code (dual compile only for IVT & gate page which has fixed size and
performance killer)
		Pros: flexible for future ASM code (just use same MACRO,
no dual compile requirement).
		Cons: 2 sets of solution for ASM code, and also slightly
performance lose due to indirect function call (future patching will
convert it to direct function call, or in place code.)
		

	Any suggestions?

	Thanks, eddie
