From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 30 Jan 2003 00:07:51 +0000
Subject: [Linux-ia64] Confused about fsystemcalls
Message-Id: <marc-linux-ia64-105590709805774@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
   We're tryign to use the fast system call stuff here, but our
measurements show way more overhead than the standard `break'
mechanism. I suspect we're doing something badly wrong.

We've written a little stub to call the fast system call entry point
directly (to save trying to get into libc).

Here it is (I know there are more stop bits than necessary).

#include <asm/asmmacro.h>
	GLOBAL_ENTRY(mygetpid)
        .prologue
	.save ar.pfs, r11
	mov r11 = ar.pfs
	.body
	movl r2 = 0xa000000000020000;; // start of gate page
	mov b7 = r2;;
	mov r15 = 1041;;
	br.call.sptk.many b6 = b7;;
	.restore sp
	mov ar.pfs = r11
	br.ret.sptk.many rp;;
	END(mygetpid)

In System.map, syscall_via_epc and __start_gate_section have the same
value, 0xe000000004a50000, so I figure  the address in user space of
syscall_via_epc is GATE_ADDR (0xa000000000000000 + 2*PERCPU_PAGE_SIZE)

The mygetpid() call appears to return the correct value.

Our figures show over an average of ten runs:
    --- glibc getpid() takes 579 cycles, stddev 24
    --- mygetpid takes 1468 cycles, stddev 286


I was also a little confused about the entry put into the ELF AUX vector --
was the value or the user-space address of syscall_via_epc meant to go
into the vector? 
Currently it says in include/asm-ia64/elf.h

#define ARCH_DLINFO					\
do {
\
	extern int syscall_via_epc;			\
	NEW_AUX_ENT(AT_SYSINFO, syscall_via_epc);	\
} while (0)


I keep thinking this should be
  extern char syscall_via_epc[];
  extern char__start_gate_section[];
  NEW_AUX_ENT(AT_SYSINFO, syscall_via_epc - __start_gate_section +
GATE_ADDR);

Peter C

