From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 10 Oct 2003 00:55:54 +0000
Subject: [PATCH] a little more documentation in fsys.txt
MIME-Version: 1
Content-Type: multipart/mixed; boundary="pQhZXvAqiZgbeUkD"
Message-Id: <marc-linux-ia64-106574771001988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Attached is a suggestion for a small addition to fsys.txt about how
userspace can use fast system calls.

If people think this is totally wrong, or that something like this
might be more appropriate in our WiKi, that's fine.

Thanks,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fsys.txt.diff"

===== Documentation/ia64/fsys.txt 1.5 vs edited =====
--- 1.5/Documentation/ia64/fsys.txt	Wed Feb 12 19:11:32 2003
+++ edited/Documentation/ia64/fsys.txt	Fri Oct 10 10:49:44 2003
@@ -229,3 +229,52 @@
 PSR.bn	Unchanged.  Note: fsys-mode handlers may clear the bit, if needed.
 	Doing so requires clearing PSR.i and PSR.ic as well.
 PSR.ia	Unchanged.  Note: the ia64 linux kernel never sets this bit.
+
+* Using fast system calls
+
+To use fast system calls, userspace applications need simply call
+__kernel_syscall_via_epc().  For example
+
+-- example fgettimeofday() call --
+-- fgettimeofday.S --
+
+#include <asm/asmmacro.h>
+
+GLOBAL_ENTRY(fgettimeofday)
+.prologue
+.save ar.pfs, r11
+mov r11 = ar.pfs
+.body 
+
+mov r2 = 0xa000000000020660;;  // gate address 
+			       // found by inspection of System.map for the 
+			       // __kernel_syscall_via_epc() function.  See
+			       // below for how to do this for real.
+
+mov b7 = r2
+mov r15 = 1087		       // gettimeofday syscall
+;;
+br.call.sptk.many b6 = b7
+;;
+
+.restore sp
+
+mov ar.pfs = r11
+br.ret.sptk.many rp;;	      // return to caller
+END(fgettimeofday)
+
+-- end fgettimeofday.S --
+
+In reality, getting the gate address is accomplished by two extra
+values passed via the ELF auxiliary vector (include/asm-ia64/elf.h)
+
+ o AT_SYSINFO : is the address of __kernel_syscall_via_epc()
+ o AT_SYSINFO_EHDR : is the address of the kernel gate ELF DSO
+
+The ELF DSO is a pre-linked library that is mapped in by the kernel at
+the gate page.  It is a proper ELF shared object so, with a dynamic
+loader that recognises the library, you should be able to make calls to
+the exported functions within it as with any other shared library.
+AT_SYSINFO points into the kernel DSO at the
+__kernel_syscall_via_epc() function for historical reasons (it was
+used before the kernel DSO) and as a convenience.

--pQhZXvAqiZgbeUkD--
