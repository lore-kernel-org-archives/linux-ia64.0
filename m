From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 10 May 2001 08:55:13 +0000
Subject: [Linux-ia64] Replacements for local_irq_xxx()
Message-Id: <marc-linux-ia64-105590693005562@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Existing local_irq_xxx() routines clear psr.i which masks all
interrupts, including NMI.  Then the only way to get the attention of a
cpu in a disabled spin loop is via INIT which is too drastic.  How
about these alternatives which set cr.tpr.mmi instead, masking all
external interrupts except NMI?

This is not complete, I have to do the debugging versions plus check
out callers of ia64_{get,set}_tpr and resolve any conflicts.  Before I
do any more work, is it worth continuing with this or do we live with
psr.i and accept that the only remedy for a cpu that is hung in a
disabled spin loop is to reboot the entire machine?

/* Nothing changes cr.tpr except local_irq_xxx() and they should always
 * leave tpr in the same state that they found it, so there is no need
 * to serialize access to tpr.  If this is incorrect, uncomment the
 * references to psr and the following srlz.d and add r15 to the clobbers.
 */

# define local_irq_save(x)						\
do {									\
	__asm__ __volatile__ (						\
	";;\n\t"							\
	"# mov r15=psr;\n\t"						\
	"mov r17=(1 << 16);\n\t"					\
	"# ;; rsm psr.i;;\n\t"						\
	"mov %0=cr.tpr;;\n\t"						\
	"or r17=r17,%0;;\n\t"						\
	"mov cr.tpr=r17;;\n\t"						\
	"srlz.d;;\n\t"							\
	"# mov psr.l=r15;;\n\t"						\
	"# srlz.d;;\n\t"						\
	: "=r" (x) : : "r16", "r17");					\
} while (0)

# define local_irq_disable()						\
do {									\
	__asm__ __volatile__ (						\
	";;\n\t"							\
	"# mov r15=psr;\n\t"						\
	"mov r17=(1 << 16);\n\t"					\
	"# ;; rsm psr.i;;\n\t"						\
	"mov r16=cr.tpr;;\n\t"						\
	"or r17=r17,r16;;\n\t"						\
	"mov cr.tpr=r17;;\n\t"						\
	"srlz.d;;\n\t"							\
	"# mov psr.l=r15;;\n\t"						\
	"# srlz.d;;\n\t"						\
	: : : "r16", "r17");						\
} while (0)

# define local_irq_restore(x)						\
do {									\
	__asm__ __volatile__ (						\
	";;\n\t"							\
	"# mov r15=psr;\n\t"						\
	"# rsm psr.i;;\n\t"						\
	"mov cr.tpr=%0;;\n\t"						\
	"srlz.d;;\n\t"							\
	"# mov psr.l=r15;;\n\t"						\
	"# srlz.d;;\n\t"						\
	: : "r" (x) );							\
} while (0)


