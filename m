From: Omar Stradella <omar@sgi.com>
Date: Thu, 11 May 2000 18:24:56 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205081@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK. So, I linked my application with -Wl,-relax (using
gnupro-2.9-000501p2) and run it on the new kernel
(2.3.99-pre6-000501-19smp). Now it goes past the _libc_main call but it
gets a SEGV in __do_global_ctors_aux (same a reported in message with
subject "ld failure"):

Program received signal SIGSEGV, Segmentation fault.
0x400000000158eb50 in __do_global_ctors_aux ()
(gdb) bt
#0  0x400000000158eb50 in __do_global_ctors_aux ()
#1  0x4000000000001c20 in _init ()
(gdb) x/4i 0x400000000158eb40
0x400000000158eb40 <__do_global_ctors_aux>:
    [MII]       alloc r34=ar.pfs,4,4,0
0x400000000158eb41 <__do_global_ctors_aux+1>:               addl r32B40,r1
0x400000000158eb42 <__do_global_ctors_aux+2>:
                cmp.eq p0,p6=r0,r0;;
0x400000000158eb50 <__do_global_ctors_aux+16>:  [MFI]       ld8 r32=[r32]
(gdb) p/x $r1
$2 = 0x0

it looks like the gp got corrupted.

Omar.
+---------------------------------------------------------------------+
Omar G. Stradella, Ph.D.                    
SGI / Chemistry and Biology Applications Group
1 Cabot Rd, Suite 250, Hudson, MA 01749, USA    N 42 22'40" W 71 33'37"
E-mail: omar@sgi.com        Phone: +1-781-839-2258 FAX: +1-978-562-7450 
http://www.sgi.com/chembio                  http://reality.sgi.com/omar 
+--------  Ph-nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn  -------+



