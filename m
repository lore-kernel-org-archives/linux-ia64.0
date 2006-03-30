From: Jes Sorensen <jes@sgi.com>
Date: Thu, 30 Mar 2006 12:29:15 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <yq0bqvoundw.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "James" = James Bottomley <James.Bottomley@SteelEye.com> writes:

James> No, I can confirm that reverting

James> [IA64] MCA Recovery: kernel context recovery table

James> fixes my boot problems.

James> I actually got slightly further than Jes with the analysis.
James> The problem occurs because something in this changeset makes
James> code that dynamically loads the TLS libraries segfault.  If you
James> look, Jes, you'll find init is continually segfaulting and
James> respawning.

Yay!

I am not the only one seeing this! I am not insane!

I bet that if you revert the patch above but then add these two lines
to arch/ia64/kernel/gate.S you'll see the same failure:

	.section "__mca_table", "a"
	.previous

Tracked it down further. If I take the gate.o file from a  working
kernel and copy it into the broken tree and run make again, the
resulting kernel boots.

I compared the code between a working and a broken gate.o with objdump
and it's identical. However the good file is 3552 bytes whereas the
broken one is 3648.

objdump -h reveals one extra empty section which seems to be what
makes all the difference. The below output is from a broken gate.o,
the only difference I can find comparing it to the good one is that
idx 4 is missing in the good one and the following ones are
renamed. Do we have some strange restrictions in the linker on the
number of sections it can handle?

Cheers,
Jes


gate.o:     file format elf64-ia64-little

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         000003b0  0000000000000000  0000000000000000  00000040  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .data         00000000  0000000000000000  0000000000000000  000003f0  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  0000000000000000  0000000000000000  000003f0  2**0
                  ALLOC
  3 __ex_table    00000000  0000000000000000  0000000000000000  000003f0  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 __mca_table   00000000  0000000000000000  0000000000000000  000003f0  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .data.patch.vtop 00000000  0000000000000000  0000000000000000  000003f0  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  6 .data.patch.mckinley_e9 00000004  0000000000000000  0000000000000000  000003f0  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  7 .data.patch.fsyscall_table 00000004  0000000000000000  0000000000000000  000003f4  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  8 .data.patch.brl_fsys_bubble_down 00000004  0000000000000000  0000000000000000  000003f8  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, DATA
  9 .IA_64.unwind_info 000000b8  0000000000000000  0000000000000000  00000400  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 10 .IA_64.unwind 00000048  0000000000000000  0000000000000000  000004b8  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
