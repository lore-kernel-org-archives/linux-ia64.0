From: Mikael Pettersson <mikpe@csd.uu.se>
Date: Tue, 20 Dec 2005 11:19:47 +0000
Subject: Re: [Perfctr-devel] Re: quick overview of the perfmon2 interface
Message-Id: <17319.59603.761669.480900@alkaid.it.uu.se>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051219113140.GC2690@frankl.hpl.hp.com>
	<20051220025156.a86b418f.akpm@osdl.org>
In-Reply-To: <20051220025156.a86b418f.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: eranian@hpl.hp.com, linux-kernel@vger.kernel.org, perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, perfctr-devel@lists.sourceforge.net

Andrew Morton writes:
 > > 		- All Itanium processors (Itanium, McKinley/Madison, Montecito)
 > > 		- Intel EM64T/Xeon. Includes support for PEBS and HyperThreading (produced by Intel)
 > > 		- Intel P4/Xeon (32-bit). Includes support for PEBS and HyperThreading
 > > 		- Intel Pentium M and P6 processors
 > > 		- AMD 64-bit Opteron
 > > 		- preliminary support for IBM Power 5 (produced by IBM)
 > > 		- preliminary support for MIPS R5000 (produced by Phil Mucci)
 > 
 > Which achitectures does perfctr support?   More, I think?

The sets are incomparable.

Intel P5 up to P4/Xeon/EM64T, though not P4's PEBS.
AMD K7 and K8.
X86 clones with performance counters (VIA C3 and Cyrix' P5-clones).
Any x86 with TSC. (Still useful for accurate time measurements.)
PPC32 (604 up to 74xx).
Any PPC32 with TB. (Still useful for accurate time measurements.)
POWER4/G5/POWER5 (done by David Gibson not me).

Preliminary ARM/XScale support is working but stalled due to
more pressing commitments and unresolved ARM platform issues.
(Some XScale/PXA drivers clobber the PMU registers for no good reason.)

UltraSPARC would be trivial to support, except (1) I don't have one,
and (2) they already have a primitive pre-historic perfctr facility.

/Mikael
