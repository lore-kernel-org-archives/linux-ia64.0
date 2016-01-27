From: "Maciej W. Rozycki" <macro@imgtec.com>
Date: Wed, 27 Jan 2016 12:09:32 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <alpine.DEB.2.00.1601271126350.5958@tp.orcam.me.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <5696CF08.8080700@imgtec.com> <20160114121449.GC15828@arm.com> <5697F6D2.60409@imgtec.com> <20160114203430.GC3818@linux.vnet.ibm.com> <56980C91.1010403@imgtec.com> <20160114212913.GF3818@linux.vnet.ibm.com> <569814F2.50801@imgtec.com>
 <20160114225510.GJ3818@linux.vnet.ibm.com> <56983054.4070807@imgtec.com> <20160115004753.GN3818@linux.vnet.ibm.com> <20160127104032.GB2939@linux-mips.org>
In-Reply-To: <20160127104032.GB2939@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Matt Redfearn <matt.redfearn@imgtec.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, 27 Jan 2016, Ralf Baechle wrote:

> > So you need to build a different kernel for some types of MIPS systems?
> 
> Yes.  We can't really do without.  Classic MIPS code is not relocatable
> without the complexity of PIC code as used by ELF DSOs - and their
> performanc penalty.  Plus we have a number of architecture revisions
> ovr the decades, big and little endian, 32 and 64 bit as the major
> stumbling stones.  There however are groups of similar systems that
> can share kernel binaries.

 Matt (cc-ed) has recently posted patches to add support for a relocatable 
kernel, implemented without the usual overhead of PIC code.  It works by 
retaining relocations in a fully-linked binary and then simply replaying 
the work the static linker does when assigning addresses, as the image 
loaded is copied to its intended destination at an early bootstrap stage.  
See: 
<http://www.linux-mips.org/cgi-bin/mesg.cgi?a=linux-mips&i49137297-30464-1-git-send-email-matt.redfearn%40imgtec.com> 
for details.

 I think this framework can be reused by carefully choosing instructions 
used in early bootstrap code, up to the relocation stage, so that it is 
runnable anywhere (not the same as PIC!) like early ld.so initialisation 
and then loading the whole attached image starting from an address where 
RAM does exist on target hardware.

 Endianness is a different matter, obviously we can't build a single image 
for both, although for distributions' sake an approach similar to one used 
with bi-endian firmware (for hardware which has an easy way to switch the 
endianness, e.g. a physical jumper or a configuration bit stored in flash 
memory; not to be confused with the reverse user endianness mode) might be 
feasible, by glueing two kernel images together and then selecting the 
right one early in bootstrap, perhaps again reusing Matt's framework.  
I'm not sure if this is worth the effort though, I suspect the usage level 
of this feature would be minimal.

 All in all I think making a generic MIPS kernel just might be feasible, 
but with the diversity of options available the effort required would be 
enormous.  NetBSD for example I believe supports building a kernel that 
correctly runs on both R3000 (MIPS I, 32-bit) and R4000 (MIPS III, 64-bit) 
DEC hardware (as did DEC Ultrix, the vendor OS for these systems).  These 
processors are different enough from each other that you cannot use the 
same code for cache, memory and exception management in an OS kernel -- 
backward compatibility is only provided for user software.  That proves 
the concept, however in a very limited way only, not even covering SMP, 
and their R4000 kernel does not support 64-bit userland I believe.  They 
still have completely separate ports for other MIPS hardware, such as for 
Broadcom SiByte SB-1 (MIPS64r1) processors.

  Maciej
