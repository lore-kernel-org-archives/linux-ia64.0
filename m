From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Fri, 16 Dec 2005 03:09:18 +0000
Subject: Linux-on-Linux for IA64
Message-Id: <17314.12254.972129.658644@berry.gelato.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Folks,
	Ever wanted UML-like functionality for Itanium?  Now you can
have it!

This week we made the first release of Linux-On-Linux, a
paravirtualised system that allows Linux to be used as a hypervisor.

You can get it from
http://www.ertos.nicta.com.au/software/virtualisation/

The package consists of a virtual machine monitor that runs in
userspace on a lightly-patched kernel, a perl script to rewrite
assembly language for automatic paravirtualisation
(previrtualisation, or compiler afterburning), and patches for host
and guest.

The host patches are primarily to add extra functionality to ptrace.
You can live without them, but the virtualised system runs very
slowly, and incorrectly if any floating point ops are done.  I've also
included Peter William's PlugSched patches, which are useful if you're
running multiple virtual machines and want to carve up the real
machine's CPU power.

The guest patches are primarily to rearrange the memory regions so as
not to collide with the host kernel's use of regions 5 through 7, and
to add in the wedge for interfacing with the afterburner.

I'll post the patches here for comment next week; I'm unhappy about the ptrace
improvement patch, and would like to know a better way to do things.

Performance with all the patches is around 70% of the bare-metal
performance for many macro benchmarks; address space switching and
creation are the main slowdowns in microbenchmark testing.

The virtualisation technique we use (previrtualisation, or compiler
afterburning) is to replace the assembler with a perl script that
modifies the code on the fly then invokes the real assembler.  This
means we don't have to modify binutils at all --- just compile the
guest kernel with some extra Makefile arguments.

--
Dr Peter Chubb     http://www.gelato.unsw.edu.au  peterc@gelato.unsw.edu.au
National ICT Australia				  http://ertos.nicta.com.au 

