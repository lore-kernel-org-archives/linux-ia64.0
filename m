From: Bob Montgomery <bob.montgomery@hp.com>
Date: Fri, 28 Jan 2005 22:00:56 +0000
Subject: [PATCH] ia64: fix bad emulation of unaligned semaphore opcodes
Message-Id: <1106949656.11657.4.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Tony,

The method used to categorize the load/store instructions in
arch/ia64/kernel/unaligned.c is masking the entire set of instructions
described in Table 4-33 of the 2002 Intel Itanium Volume 3: Instruction
Set Reference.

It's the set of instructions for opcode 4, mbit 0, x bit 1, described
as Semaphore/Get FR/16-Byte Opcode Instructions.

Because the IA64_OPCODE_SHIFT and IA64_OPCODE_MASK operations ignore
the x bit, this set of instructions (including cmpxchg, xchg, and
fetchadd among others) are processed like the corresponding opcode 4,
mbit 0, x bit 0 instructions.

This means that a cmpxchg.acq with a misaligned pointer will return the
old value without setting the new one (rendering spin locks as No-ops)
and that the other instructions also appear not to update memory.
A cmpxchg.rel will be treated like a ld.s and just retry forever.

The correct behavior for this class of instructions is documented
in the file as producing failures for user code and kernel oops in
kernel mode, but the code as implemented does not behave this way.

I have user test code to demonstrate the problem if you would like
a copy.

The simple fix in this patch has been discussed with Stephane Eranian
and David Mosberger.  It has the advantage of not requiring the
redesign of the opcode discrimination in unaligned.c.

Signed-off-by: Bob Montgomery <bob.montgomery@hp.com>


--- linux-2.6.10-bobm/arch/ia64/kernel/unaligned.c.orig	2005-01-28 14:23:52.290350614 -0700
+++ linux-2.6.10-bobm/arch/ia64/kernel/unaligned.c	2005-01-28 14:13:29.828444177 -0700
@@ -1380,6 +1380,10 @@ ia64_handle_unaligned (unsigned long ifa
 	 *		- ldX.spill
 	 *		- stX.spill
 	 *	Reason: RNATs are based on addresses
+	 *		- ld16
+	 *		- st16
+	 *	Reason: ld16 and st16 are supposed to occur in a single
+	 *		memory op
 	 *
 	 *	synchronization:
 	 *		- cmpxchg
@@ -1401,6 +1405,10 @@ ia64_handle_unaligned (unsigned long ifa
 	switch (opcode) {
 	      case LDS_OP:
 	      case LDSA_OP:
+		if (u.insn.x)
+			/* oops, really a semaphore op (cmpxchg, etc) */
+			goto failure;
+		/* no break */
 	      case LDS_IMM_OP:
 	      case LDSA_IMM_OP:
 	      case LDFS_OP:
@@ -1425,6 +1433,10 @@ ia64_handle_unaligned (unsigned long ifa
 	      case LDCCLR_OP:
 	      case LDCNC_OP:
 	      case LDCCLRACQ_OP:
+		if (u.insn.x)
+			/* oops, really a semaphore op (cmpxchg, etc) */
+			goto failure;
+		/* no break */
 	      case LD_IMM_OP:
 	      case LDA_IMM_OP:
 	      case LDBIAS_IMM_OP:
@@ -1437,6 +1449,10 @@ ia64_handle_unaligned (unsigned long ifa
 
 	      case ST_OP:
 	      case STREL_OP:
+		if (u.insn.x)
+			/* oops, really a semaphore op (cmpxchg, etc) */
+			goto failure;
+		/* no break */
 	      case ST_IMM_OP:
 	      case STREL_IMM_OP:
 		ret = emulate_store_int(ifa, u.insn, regs);

-- 
Bob Montgomery <bob.montgomery@hp.com>

