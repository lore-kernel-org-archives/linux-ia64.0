From: Markus Schaber <markus.schaber@student.uni-ulm.de>
Date: Wed, 26 Mar 2003 11:51:40 +0000
Subject: Re: [parisc-linux] Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705314@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705314@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

m.delahaye@esiee.fr (Matthieu Delahaye) wrote:

> >   Matthew> No.  You certainly can't run a PA-RISC kernel on an IA64
> >   Matthew> box, just like you can't run an x86 kernel on an ia64
> >   box.
> > Ugh, that's not strictly true.  You definitely can boot x86 linux
> > and windows 98 on Itanium.  I believe the same is true for Itanium 2
> > if you have Intel's firmware, though I have never tried that myself.
> ...And perhaps you don't forget to add support for the chipset in the
> x86/hppa kernel. 

You definitely need IA64 Linux to make real use of an Itanium2 Machine.
(I was able to "play" on an HP 4-Way machine for some weeks.)

However, Itanium chips support X86 Emulation in Hardware, so they can
run any X86 Software without further software support (however, the
software is limited to the X86 capabilities regarding Memory Capacity
etc., and it is _really slow_, every P3/P4/Athlon at the same MHz is
uncomparable.)

As far as I know, the PA-Risc instruction mapping is done with lots of
software help. The concept is a bit like JIT-Compilers in Java. (It is
easier to do this when having a RISC code with equal instruction length
compared to ugly X86 code.) As long as my knowledge is correct, you
therefore cannot run any PA-RISC OS directly on the Hardware, but you
can run PA-RISC Software in any OS that supports the instruction
mapping, maybe one can even run a PA-RISC OS inside a virtual PA-RISC
Machine on Itaniums. (However I don't know any such VM.)

Markus

