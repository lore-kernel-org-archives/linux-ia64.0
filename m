From: n0ano@indstorage.com
Date: Mon, 21 Jan 2002 17:30:11 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805898@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FiX-

Looks like you did have a minor confusion.  The goal for IA32 support
is to run `current' IA32 applications on an IA64 Linux machine.  Creating
IA32 applications on IA64 was never a goal and that's why the IA64
GCC and tools have no support for generating IA32 instructions.

Any IA32 program, including the IA32 GCC, would require the installation
of an entire IA32 run-time environment on the IA64 machine.  Fortunately
all of the IA64 distributions provide IA32 environments as an option
so it's easy to provide this.

Mixing IA32 and IA64 instruction sets in the same program is another one
of those things that is conceptually feasible but no one supports it because
there is not enough benefit.  The biggest advantage for this would be in
shared libraries and it's not worth it even here.  If you can obtain a
current IA32 program then you can obtain the IA32 libraries that it uses
so there's no need for an IA32 program to call IA64 shared libraries.  If
you have an IA32 shared library that you want to use from an IA64 program
then you should just re-compile the library for IA64 (remember, we're
dealing with open source here).

On Mon, Jan 21, 2002 at 06:07:10PM +0100, Francois-Xavier Kowalski wrote:
> Thanks for the reply.
> 
> n0ano@indstorage.com wrote:
> 
> >I'll try and give a brief run down of the execution environments available
> >on IA64 Linux right now.  The CPU is capable of executing two different
> >instruction sets, IA64 and IA32.  For the IA64 instruction set there are
> >multiple execution modes possible, the most obvious two being LP64 (`long'
> >and `pointer are 64-bits, `int' is 32-bits) and ILP32 (`int', `long' and
> >`pointer' are all 32-bits).
> >
> >The `native' environment for IA64 Linux has been declared to be the IA64
> >instruction set running in LP64 mode.  This is fully supported by GCC,
> >GLIBC, tools and the kernel.
> >
> >Although running IA64 instructions in ILP32 mode is conceptually possible
> >it is not supported and there are no plans to support this mode any time
> >in the near future.  This would require significant changes to GCC, GLIBC
> >and the kernel at a minimum and no one has provided any compelling evidence
> >that there is enough performance gain to justify this effort.
> >
> 
> I think I am a bit confused. I was assuming that there was a difference 
> between execution of an IA32 executable compiled on a IA32 platform 
> (native IA32), and an IA32 executable compiled on a IA64 machine to run 
> in 32-bits mode.
> 
> Do I mistake?
> 
> >The IA32 support in IA64 Linux is designed more as a transition tool rather
> >than a development environment.  Our goal all along has been to support
> >executing current IA32 programs, not generating new ones.  Therefore the
> >compiler tools (GCC, the linker and what not) have no support for IA32
> >code generation.  If you really want to generate IA32 programs on an IA64
> >Linux system you can install an IA32 version of GCC and use that.
> >
> 
> Will this need to install as well a Linux/IA32 version on the whole 
> run-time environment (GLIBC & whatsoever), or will GCC be able to use 
> the native IA64 libraries?
> 
> Maybe the question above means mixing IA32 & IA64 instructions within 
> the same execution context & is forbidden.
> 
> >On Mon, Jan 21, 2002 at 04:01:25PM +0100, Francois-Xavier Kowalski wrote:
> >
> >>Hi all,
> >>
> >>I am wondering if the Linux & GCC port on ia64 allows compilation & 
> >>execution of native i64 32-bits executables (not speaking about ia32 
> >>compatibility, but native 32-bits on ia64).
> >>
> >>HP-UX & AIX (at least) have this generation & execution options, because 
> >>execution speed would be sorted as follows, in descending order:
> >>
> >>  * native 32-bits executables
> >>  * native 64-bits
> >>  * ia32 emulation
> >>
> >>I did not find any clue of that neither in the GCC web site, nor from 
> >>the "Linux on ia64" site.
> >>
> FiX
> 
> -- 
> Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
> Telecom Infrastructure Division   / //_/    Telnet: 779-6327
> SigTech eXpert                      /       http://www.hp.com/go/opencall
>                               i n v e n t
> 
> 

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

