From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 21 Jan 2002 17:27:52 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805897@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com> writes:

> n0ano@indstorage.com wrote:
> 
>>Although running IA64 instructions in ILP32 mode is conceptually possible
>>it is not supported and there are no plans to support this mode any time
>>in the near future.  This would require significant changes to GCC, GLIBC
>>and the kernel at a minimum and no one has provided any compelling evidence
>>that there is enough performance gain to justify this effort.
> 
> I think I am a bit confused. I was assuming that there was a difference 
> between execution of an IA32 executable compiled on a IA32 platform 
> (native IA32), and an IA32 executable compiled on a IA64 machine to run 
> in 32-bits mode.
> 
> Do I mistake?

The ia64 is basically two cpus in one, a real ia64 and a legacy
ia32. ia32 code is slow and runs for compatibility not
performance. What Don is talking about is that one could theoretically
run the ia64 unit in 'short' mode ie. declare pointers to be 32 bit to
save some space. However this would require a second glibc target plus
modifications to the compiler and it doesn't fit into the memory model
we are using.

There has been a few requests for this, but so far nothing convincing
enough to justify the effort. I for one has no interest in doing
another full glibc target.

> >The IA32 support in IA64 Linux is designed more as a transition tool rather
> >than a development environment.  Our goal all along has been to support
> >executing current IA32 programs, not generating new ones.  Therefore the
> >compiler tools (GCC, the linker and what not) have no support for IA32
> >code generation.  If you really want to generate IA32 programs on an IA64
> >Linux system you can install an IA32 version of GCC and use that.
> 
> Will this need to install as well a Linux/IA32 version on the whole 
> run-time environment (GLIBC & whatsoever), or will GCC be able to use 
> the native IA64 libraries?

If you want to build and run ia32 binaries, you need a complete ia32
toolchain environment and libraries.

> Maybe the question above means mixing IA32 & IA64 instructions within 
> the same execution context & is forbidden.

It's not possible.

Cheers,
Jes

