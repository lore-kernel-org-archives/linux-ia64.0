From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 21 Nov 2000 05:47:21 +0000
Subject: Re: [Linux-ia64] 001117 toolchain release
Message-Id: <marc-linux-ia64-105590678205755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 17 Nov 2000 21:34:58 -0800, 
Jim Wilson <wilson@cygnus.com> wrote:
>I have put a new toolchain on ftp.cygnus.com in pub/ia64-linux/snap-001117.
>
>This fixes all significant known toolchain problems.  I don't expect to be
>adding more patches to the toolchain unless another serious toolchain bug is
>found.

The unwind sections have alignment 2**0.  The only reason we get away
with it is that the preceding sections are aligned and are a multiple
of words.  If you add a section between __ksymtab and unwind that is
not a multiple of words then the results are "interesting".

  0 .text         0039a990  e000000000500000  0000000000500000  00010000  2**15
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 __ex_table    000019a0  e00000000089a990  000000000089a990  003aa990  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 __ksymtab     00004100  e00000000089c330  000000000089c330  003ac330  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .IA_64.unwind 000240a8  e0000000008a0430  00000000008a0430  003b0430  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .IA_64.unwind_info 0002ca00  e0000000008c44e0  00000000008c44e0  003d44e0  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA

Temporary fix, against 2.4.0-test11.

Index: 0-test11.7/arch/ia64/vmlinux.lds.S
--- 0-test11.7/arch/ia64/vmlinux.lds.S Mon, 20 Nov 2000 18:27:00 +1100 kaos (linux-2.4/b/c/8_vmlinux.ld 1.3.1.1.3.1 644)
+++ 0-test11.7(w)/arch/ia64/vmlinux.lds.S Tue, 21 Nov 2000 14:36:37 +1100 kaos (linux-2.4/b/c/8_vmlinux.ld 1.3.1.1.3.1 644)
@@ -65,9 +65,11 @@ SECTIONS
 
   /* Unwind table */
+  . = ALIGN(16);
   ia64_unw_start = .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
 	{ *(.IA_64.unwind) }
   ia64_unw_end = .;
+  . = ALIGN(16);
   .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
 	{ *(.IA_64.unwind_info) }


