From: Francois-Xavier Kowalski <francois-xavier_kowalski@hp.com>
Date: Mon, 21 Jan 2002 17:07:10 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the reply.

n0ano@indstorage.com wrote:

>I'll try and give a brief run down of the execution environments available
>on IA64 Linux right now.  The CPU is capable of executing two different
>instruction sets, IA64 and IA32.  For the IA64 instruction set there are
>multiple execution modes possible, the most obvious two being LP64 (`long'
>and `pointer are 64-bits, `int' is 32-bits) and ILP32 (`int', `long' and
>`pointer' are all 32-bits).
>
>The `native' environment for IA64 Linux has been declared to be the IA64
>instruction set running in LP64 mode.  This is fully supported by GCC,
>GLIBC, tools and the kernel.
>
>Although running IA64 instructions in ILP32 mode is conceptually possible
>it is not supported and there are no plans to support this mode any time
>in the near future.  This would require significant changes to GCC, GLIBC
>and the kernel at a minimum and no one has provided any compelling evidence
>that there is enough performance gain to justify this effort.
>

I think I am a bit confused. I was assuming that there was a difference 
between execution of an IA32 executable compiled on a IA32 platform 
(native IA32), and an IA32 executable compiled on a IA64 machine to run 
in 32-bits mode.

Do I mistake?

>The IA32 support in IA64 Linux is designed more as a transition tool rather
>than a development environment.  Our goal all along has been to support
>executing current IA32 programs, not generating new ones.  Therefore the
>compiler tools (GCC, the linker and what not) have no support for IA32
>code generation.  If you really want to generate IA32 programs on an IA64
>Linux system you can install an IA32 version of GCC and use that.
>

Will this need to install as well a Linux/IA32 version on the whole 
run-time environment (GLIBC & whatsoever), or will GCC be able to use 
the native IA64 libraries?

Maybe the question above means mixing IA32 & IA64 instructions within 
the same execution context & is forbidden.

>On Mon, Jan 21, 2002 at 04:01:25PM +0100, Francois-Xavier Kowalski wrote:
>
>>Hi all,
>>
>>I am wondering if the Linux & GCC port on ia64 allows compilation & 
>>execution of native i64 32-bits executables (not speaking about ia32 
>>compatibility, but native 32-bits on ia64).
>>
>>HP-UX & AIX (at least) have this generation & execution options, because 
>>execution speed would be sorted as follows, in descending order:
>>
>>   * native 32-bits executables
>>   * native 64-bits
>>   * ia32 emulation
>>
>>I did not find any clue of that neither in the GCC web site, nor from 
>>the "Linux on ia64" site.
>>
FiX

-- 
Francois-Xavier "FiX" KOWALSKI     /_ __    Tel:+33 (0)4 76 14 63 27
Telecom Infrastructure Division   / //_/    Telnet: 779-6327
SigTech eXpert                      /       http://www.hp.com/go/opencall
                               i n v e n t




