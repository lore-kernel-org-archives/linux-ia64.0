From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Wed, 29 Sep 2004 20:31:20 +0000
Subject: Re: kernel troubles on rx2600 while running sbuild
Message-Id: <20040929223120.46cff6df.T-Bone@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040926183333.1592f4cd@Tatooine.r3z0>
In-Reply-To: <20040926183333.1592f4cd@Tatooine.r3z0>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 29 Sep 2004 13:13:05 -0600
dann frazier <dannf@hp.com> wrote:

> > Unable to handle kernel paging request at virtual address
> > 00000000000100a6 du[3608]: Oops 8813272891392
> 
> Can you run these through ksymoops and provide the version of the
> 2.4.27 kernel you're running?

[varenet@envy ~]$ uname -a
Linux envy 2.4.27-1-mckinley #1 Fri Sep 3 13:33:45 MDT 2004 ia64
GNU/Linux

unfortunately i can't run ksymoops anymore. This system is under high
load and has to be quickly restored to a working state. The partition
containing the troublesome folder has been reinitialized (though neither
fsck nor badblocks shown anything wrong with it).

Again, i have some more reports:

back to the SMP box (2.6.8.1-1-mckinley-smp), i tried again to build
gcc-3.4_3.4.2-2ubuntu1. The build that failed on the 2.4 UP box. It
seems that i've been able to reproduce the "stall effect". Several tests
from the ADA testsuite are getting stalled for no apparent reason. The
only common thing is that they ALL get stuck issuing an Unaligned Access
with the SAME ip. (See the inlined dmesg output). I had to kill those
processes using SIGKILL, since SIGTERM had no effect.

Two things about this:
1) The PID (?) shown between parenthesis in this dump differs (it's
greater) with the PID reported in PS. These tests are single-threaded.
2) The ip looks like a shared lib, and ldd showed the following:

libgnarl-3.4.so.1 => not found
libgnat-3.4.so.1 => not found
libpthread.so.0 => /lib/tls/libpthread.so.0 (0x2000000000040000)
libc.so.6.1 => /lib/tls/libc.so.6.1 (0x2000000000070000)
/lib/ld-linux-ia64.so.2 => /lib/ld-linux-ia64.so.2 (0x2000000000000000)

unfortunately before i could change LD_LIBRARY_PATH, the build went over
and the executable were gone.

Only the ADA testsuite was affected. The rest of the build went mostly
fine (i had troubles at the very end of the process, with dpkg-*, but i
don't think this is related).

HTH,

Thibaut VARENE
The PA/Linux ESIEE Team
http://www.pateam.org/


c91004b(10788): unaligned access to 0x6000000000002469, ip=0x200000000037af71
c91004b(10788): unaligned access to 0x6000000000002469, ip=0x200000000037af71
c940010(12248): unaligned access to 0x6000000000003e59, ip=0x200000000037af71
c940010(12248): unaligned access to 0x6000000000003e59, ip=0x200000000037af71
c94002g(12929): unaligned access to 0x600000000000f709, ip=0x200000000037af71
c94002g(12929): unaligned access to 0x600000000000f709, ip=0x200000000037af71
c94007a(13287): unaligned access to 0x600000000000fbb1, ip=0x200000000037af71
c94007a(13287): unaligned access to 0x600000000000fbb1, ip=0x200000000037af71
c95022b(13988): unaligned access to 0x6000000000003cf9, ip=0x200000000037af71
c95022b(13988): unaligned access to 0x6000000000003cf9, ip=0x200000000037af71
c95022b(13988): unaligned access to 0x6000000000003cf9, ip=0x200000000037af71
c95022b(13988): unaligned access to 0x6000000000003cf9, ip=0x200000000037af71
c95072a(14703): unaligned access to 0x6000000000001cd1, ip=0x200000000037af71
c95072a(14703): unaligned access to 0x6000000000001cd1, ip=0x200000000037af71
c95072b(14744): unaligned access to 0x6000000000001f11, ip=0x200000000037af71
c95072b(14744): unaligned access to 0x6000000000001f11, ip=0x200000000037af71
c954016(16750): unaligned access to 0x6000000000002791, ip=0x200000000037af71
c954016(16750): unaligned access to 0x6000000000002791, ip=0x200000000037af71
c954017(16791): unaligned access to 0x6000000000002969, ip=0x200000000037af71
c954017(16791): unaligned access to 0x6000000000002969, ip=0x200000000037af71
c974004(19316): unaligned access to 0x60000000000019d9, ip=0x200000000037af71
c974004(19316): unaligned access to 0x60000000000019d9, ip=0x200000000037af71
c974009(19510): unaligned access to 0x6000000000000b71, ip=0x200000000037af71
c974009(19510): unaligned access to 0x6000000000000b71, ip=0x200000000037af71
c9a011a(20229): unaligned access to 0x600000000000de49, ip=0x200000000037af71
c9a011a(20229): unaligned access to 0x600000000000de49, ip=0x200000000037af71
cb1010a(23612): unaligned access to 0x60000000000014b9, ip=0x200000000037af71
cb1010a(23612): unaligned access to 0x60000000000014b9, ip=0x200000000037af71
cb20001(23724): unaligned access to 0x60000000000023c1, ip=0x200000000037af71
cb20001(23724): unaligned access to 0x60000000000023c1, ip=0x200000000037af71
cb20004(23802): unaligned access to 0x6000000000001619, ip=0x200000000037af71
cb20004(23802): unaligned access to 0x6000000000001619, ip=0x200000000037af71
cb20004(23802): unaligned access to 0x6000000000001619, ip=0x200000000037af71
cb20004(23802): unaligned access to 0x6000000000001619, ip=0x200000000037af71
cb41002(24763): unaligned access to 0x60000000000063a9, ip=0x200000000037af71
cb41002(24763): unaligned access to 0x60000000000063a9, ip=0x200000000037af71
cb5001a(24866): unaligned access to 0x600000000000e7f1, ip=0x200000000037af71
cb5001a(24866): unaligned access to 0x600000000000e7f1, ip=0x200000000037af71
cb5001b(24905): unaligned access to 0x600000000000f979, ip=0x200000000037af71
cb5001b(24905): unaligned access to 0x600000000000f979, ip=0x200000000037af71
cb5002a(24943): unaligned access to 0x6000000000001e01, ip=0x200000000037af71
cb5002a(24943): unaligned access to 0x6000000000001e01, ip=0x200000000037af71
