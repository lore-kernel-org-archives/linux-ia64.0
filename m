From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 25 Oct 2004 15:33:14 +0000
Subject: Re: newbie question about 2.6 ia64 linux-gate etc
Message-Id: <16765.7354.650202.130073@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAY14-F23L9BGTuAyHs000156b6@hotmail.com>
In-Reply-To: <BAY14-F23L9BGTuAyHs000156b6@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 25 Oct 2004 10:57:25 -0400, "Raj Patil" <rpatil0299@hotmail.com> said:

  Raj> Hello, I am looking for some basic info on how the
  Raj> linux-gate.so is used and how it gets mapped to the process
  Raj> address space in 2.6 ia64 and how all the system call function
  Raj> names gets included here? (I have access to SuSE 9.0, based on
  Raj> 2.6.5-7.97)

  Raj> Can some please point/direct me to some doc/notes, if it exists
  Raj> or write few lines to give some basic information information
  Raj> about these?

  Raj> Thank you very much and really appreciate info.

See the last section "Using fast system calls" of

	Documentation/ia64/fsys.txt

I'll append it below for convenience.

BTW: The vDSO approach isn't unique to ia64.  It was invented for x86
and other platforms use it as well.

	--david


----
* Using fast system calls

To use fast system calls, userspace applications need simply call
__kernel_syscall_via_epc().  For example

-- example fgettimeofday() call --
-- fgettimeofday.S --

#include <asm/asmmacro.h>

GLOBAL_ENTRY(fgettimeofday)
.prologue
.save ar.pfs, r11
mov r11 = ar.pfs
.body 

mov r2 = 0xa000000000020660;;  // gate address 
			       // found by inspection of System.map for the 
			       // __kernel_syscall_via_epc() function.  See
			       // below for how to do this for real.

mov b7 = r2
mov r15 = 1087		       // gettimeofday syscall
;;
br.call.sptk.many b6 = b7
;;

.restore sp

mov ar.pfs = r11
br.ret.sptk.many rp;;	      // return to caller
END(fgettimeofday)

-- end fgettimeofday.S --

In reality, getting the gate address is accomplished by two extra
values passed via the ELF auxiliary vector (include/asm-ia64/elf.h)

 o AT_SYSINFO : is the address of __kernel_syscall_via_epc()
 o AT_SYSINFO_EHDR : is the address of the kernel gate ELF DSO

The ELF DSO is a pre-linked library that is mapped in by the kernel at
the gate page.  It is a proper ELF shared object so, with a dynamic
loader that recognises the library, you should be able to make calls to
the exported functions within it as with any other shared library.
AT_SYSINFO points into the kernel DSO at the
__kernel_syscall_via_epc() function for historical reasons (it was
used before the kernel DSO) and as a convenience.
