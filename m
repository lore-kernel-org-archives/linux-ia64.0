From: Dennis Clarke <dclarke@blastwave.org>
Date: Wed, 01 Feb 2012 17:52:31 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <64097.10.0.66.17.1328118751.squirrel@interact.purplecow.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
In-Reply-To: <20120201151918.GC16714@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <jkosina@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Colin Walters <walters@verbum.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org


> I have actually tried exactly this earlier today (because while looking at
> this, I had an idea that putting volatile in place could be a workaround,
> causing gcc to generate a saner code), but it doesn't work either:
>
> # cat x.c
> struct x {
>     long a;
>     volatile unsigned int lock;
>     unsigned int full:1;
> };
>
> void
> wrong(struct x *ptr)
> {
>         ptr->full = 1;
> }
>
> int main()
> {
>         wrong(0);
> }
<snip>
> In my opinion, this is a clear bug in gcc (while the original problem,
> without explitict volatile, is not a C spec violation per se, it's just
> very inconvenient :) ).

As a data point, the exact same code on a Solaris 8 pentium III box:

$ gcc -S -o x.s x.c
$ cat x.s
        .file   "x.c"
        .text
.globl wrong
        .type   wrong, @function
wrong:
        pushl   %ebp
        movl    %esp, %ebp
        movl    8(%ebp), %eax
        movzbl  8(%eax), %edx
        orl     $1, %edx
        movb    %dl, 8(%eax)
        popl    %ebp
        ret
        .size   wrong, .-wrong
.globl main
        .type   main, @function
main:
        pushl   %ebp
        movl    %esp, %ebp
        subl    $4, %esp
        movl    $0, (%esp)
        call    wrong
        leave
        ret
        .size   main, .-main
        .ident  "GCC: (Blastwave.org Inc. Thu Dec 16 18:05:01 GMT 2010) 4.5.2"
$ gcc -o x x.c
$ file x
x:              ELF 32-bit LSB executable 80386 Version 1, dynamically linked,
not stripped
$ ldd x
        libc.so.1 =>     /usr/lib/libc.so.1
        libdl.so.1 =>    /usr/lib/libdl.so.1
$ ./x
Segmentation Fault(coredump)

$ ls -l core
-rw-------   1 dclarke  csw        71384 Feb  1 17:26 core

71384 bytes core is complete thus :

$  elfdump -p core | tail -6

Program Header[12]:
    p_vaddr:      0xdfbf3000      p_flags:    [ PF_X  PF_W  PF_R ]
    p_paddr:      0               p_type:     [ PT_LOAD ]
    p_filesz:     0x1000          p_memsz:    0x1000
    p_offset:     0x106d8         p_align:    0

$ /opt/studio/SOS11/SUNWspro/bin/dbx -c "print 0x1000 + 0x106d8; quit"
dbx: warning: unknown language, 'c' assumed
0x1000+0x106d8 = 71384

what caused the seg fault ?

$ /opt/studio/SOS11/SUNWspro/bin/dbx x core
Reading x
core file header read successfully
Reading ld.so.1
Reading libc.so.1
Reading libdl.so.1
program terminated by signal SEGV (no mapping at the fault address)
0x08050672: wrong+0x0006:       movzbl   0x00000008(%eax),%edx
(dbx) where
=>[1] wrong(0x0, 0x8047b70, 0x805057d, 0x1, 0x8047b7c, 0x8047b84), at 0x8050672
  [2] main(0x1, 0x8047b7c, 0x8047b84), at 0x8050690

However Sun Studio 5.8 does no better :

$ /opt/studio/SOS11/SUNWspro/bin/cc -Xc -o x_Sun_Studio_5.8 x.c
$ ./x_Sun_Studio_5.8
Segmentation Fault(coredump)
$ ls -l core
-rw-------   1 dclarke  csw        71384 Feb  1 17:48 core

$ /opt/studio/SOS11/SUNWspro/bin/dbx x_Sun_Studio_5.8 core
dbx: warning: core object name "x_Sun_Studio_5." matches
object name "x_Sun_Studio_5.8" within the limit of 14. assuming they match
core file header read successfully
Reading ld.so.1
Reading libc.so.1
Reading libdl.so.1
program terminated by signal SEGV (no mapping at the fault address)
0x080506ae: wrong+0x000e:       movl     0x00000008(%ecx),%eax
(dbx) where
=>[1] wrong(0x0), at 0x80506ae
  [2] main(0x1, 0x8047b4c, 0x8047b54), at 0x80506ca
(dbx) quit
$ /opt/studio/SOS11/SUNWspro/bin/cc -V
cc: Sun C 5.8 Patch 121016-08 2009/04/20
usage: cc [ options] files.  Use 'cc -flags' for details
$


dc


-- 
--
http://pgp.mit.edu:11371/pks/lookup?op=vindex&search=0x1D936C72FA35B44B
+-------------------------+-----------------------------------+
| Dennis Clarke           | Solaris and Linux and Open Source |
| dclarke@blastwave.org   | Respect for open standards.       |
+-------------------------+-----------------------------------+

