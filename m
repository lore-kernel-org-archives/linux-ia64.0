From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Thu, 27 Feb 2003 19:24:38 +0000
Subject: RE: [Linux-ia64] IA64/ecc - Problems with system.h
Message-Id: <marc-linux-ia64-105590709805940@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805939@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805939@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Manoj,

ecc doesn't support asm stmts. We need to replace all asm stmts into compiler dependent intrinsics. This is work in progress.

thanks,
suresh

> -----Original Message-----
> From: Manoj Kumar Krishnan [mailto:manoj1@ERC.MsState.Edu]
> Sent: Thursday, February 27, 2003 11:10 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] IA64/ecc - Problems with system.h
> 
> 
> 
> I'm having trouble in getting my code compiled using Intel 
> Compilers (6.0
> or 7.0) in Linux-IA64. Anyhelp would be appreaciated. Thanks!
> 
> --------------------------------------------------------------------
> 
> ecc -O -w1 -c -o shmem.o shmem.c
> 
> /usr/include/asm/system.h(74): error: asm statements not 
> supported in this
> environment
>         __asm__ __volatile__ (";;" ::: "memory");
>         ^
> 
> /usr/include/asm/system.h(74): error: expected a ")"
>         __asm__ __volatile__ (";;" ::: "memory");
>                                    ^
> 
> /usr/include/asm/system.h(260): error: asm statements not supported in
> this environment
>                 __asm__ __volatile (IA64_SEMFIX"xchg1 
> %0=[%1],%2" : "=r"
> (result)
>                 ^
> 
> /usr/include/asm/system.h(260): error: expected a ")"
>                 __asm__ __volatile (IA64_SEMFIX"xchg1 
> %0=[%1],%2" : "=r"
> (result)
>                                                                   ^
> 
> /usr/include/asm/system.h(265): error: asm statements not supported in
> this environment
>                 __asm__ __volatile (IA64_SEMFIX"xchg2 
> %0=[%1],%2" : "=r"
> (result)
>                 ^
> 
> /usr/include/asm/system.h(265): error: expected a ")"
>                 __asm__ __volatile (IA64_SEMFIX"xchg2 
> %0=[%1],%2" : "=r"
> (result)
>                                                                   ^
> 
> /usr/include/asm/system.h(270): error: asm statements not supported in
> this environment
>                 __asm__ __volatile (IA64_SEMFIX"xchg4 
> %0=[%1],%2" : "=r"
> (result)
>                 ^
> 
> /usr/include/asm/system.h(270): error: expected a ")"
>                 __asm__ __volatile (IA64_SEMFIX"xchg4 
> %0=[%1],%2" : "=r"
> (result)
>                                                                   ^
> 
> /usr/include/asm/system.h(275): error: asm statements not supported in
> this environment
>                 __asm__ __volatile (IA64_SEMFIX"xchg8 
> %0=[%1],%2" : "=r"
> (result)
>                 ^
> 
> /usr/include/asm/system.h(275): error: expected a ")"
>                 __asm__ __volatile (IA64_SEMFIX"xchg8 
> %0=[%1],%2" : "=r"
> (result)
>                                                                   ^
> 
> compilation aborted for shmem.c (code 2)
> 
> ----------------------------------------------------------------------
> 
> -Manoj:)
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

