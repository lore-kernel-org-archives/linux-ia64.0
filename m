From: n0ano@n0ano.com
Date: Wed, 26 Mar 2003 16:25:35 +0000
Subject: Re: [parisc-linux] Re: [Linux-ia64] Linux, Itanium and PA/RISC
Message-Id: <marc-linux-ia64-105590723705319@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705314@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705314@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Well, Itanium's can sort of run any X86 software.

As David was alluding to there are two ways you can boot an Itanium
box, either with an IA32 kernel (a current Pentium based OS) or an
IA64 kernel.

If you boot an IA32 kernel the CPU will behave as an exact Pentium
processor and execute all Pentium code.  The system will be slower
than comparable Pentium processors but it should work exactly the
same.  (Notice that I say `should', I've never done this, there could
be chipset issues, I don't know of anyone who has done this but it
should work.)

If you boot an IA64 kernel then the CPU can execute IA32 user mode
programs.  This means you can't run IA32 device drivers and it also
means you need a fair amount of kernel support in order to run an
IA32 application so the statement `without further software support'
is a little inaccurate.

On Wed, Mar 26, 2003 at 12:51:40PM +0100, Markus Schaber wrote:
>
>...
> 
> However, Itanium chips support X86 Emulation in Hardware, so they can
> run any X86 Software without further software support (however, the
> software is limited to the X86 capabilities regarding Memory Capacity
> etc., and it is _really slow_, every P3/P4/Athlon at the same MHz is
> uncomparable.)
> 
>...

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@n0ano.com
Ph: 303/447-2201

