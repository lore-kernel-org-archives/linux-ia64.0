From: n0ano@indstorage.com
Date: Fri, 31 May 2002 14:25:32 +0000
Subject: Re: [Linux-ia64] Building native 32 bit binaries
Message-Id: <marc-linux-ia64-105590701905627@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905624@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905624@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gregor-

I'm not totally sure what you're asking for but I'll attempt to answer
your question anyway.

First some background.  The IA64 CPU is capable of executing 2 different
instruction sets, IA32 and IA64.  Additionally, the IA64 instruction set
can deal with multiple data size conventions.

Legacy IA32 applications, typically created on an IA32 machine, run
on IA64 Linux.

The only data size convention supported for the IA64 instruction set is
LP64 (long's and pointers are 64-bits wide and int's are 32-bits wide).

Although it is technically possible to support ILP32 (int's, long's and
pointers are 32-bits wide) IA64 Linux does not support this.  The benefits
of ILP32 are small and the problems that would arise in library support,
kernel support and system managment are just too huge.  The IA64 Linux
development team has made a conscious decision not to support ILP32.

On Fri, May 31, 2002 at 12:24:50PM +0200, knightgun@email.si wrote:
> Hello,
> 
> i have a question regarding 32 bit binaries on IA-64 linux.
> I am using RedHat 7.1 with gcc 2.96 and kernel 2.4.3-12smp.
> 
> I have build 32bit binaries on an x86 system and these work just fine however I 
> need to build IA-64 native 32bit binaries. Is this possible and how ?
> 
> Thank you in advance,
> 
> Gregor
> 
> 
> 
> -------------------
> http://www.email.si
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

