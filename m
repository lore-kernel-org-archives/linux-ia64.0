From: Manoj Kumar Krishnan <manoj1@ERC.MsState.Edu>
Date: Thu, 27 Feb 2003 19:09:50 +0000
Subject: [Linux-ia64] IA64/ecc - Problems with system.h
Message-Id: <marc-linux-ia64-105590709805939@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm having trouble in getting my code compiled using Intel Compilers (6.0
or 7.0) in Linux-IA64. Anyhelp would be appreaciated. Thanks!

--------------------------------------------------------------------

ecc -O -w1 -c -o shmem.o shmem.c

/usr/include/asm/system.h(74): error: asm statements not supported in this
environment
        __asm__ __volatile__ (";;" ::: "memory");
        ^

/usr/include/asm/system.h(74): error: expected a ")"
        __asm__ __volatile__ (";;" ::: "memory");
                                   ^

/usr/include/asm/system.h(260): error: asm statements not supported in
this environment
                __asm__ __volatile (IA64_SEMFIX"xchg1 %0=[%1],%2" : "=r"
(result)
                ^

/usr/include/asm/system.h(260): error: expected a ")"
                __asm__ __volatile (IA64_SEMFIX"xchg1 %0=[%1],%2" : "=r"
(result)
                                                                  ^

/usr/include/asm/system.h(265): error: asm statements not supported in
this environment
                __asm__ __volatile (IA64_SEMFIX"xchg2 %0=[%1],%2" : "=r"
(result)
                ^

/usr/include/asm/system.h(265): error: expected a ")"
                __asm__ __volatile (IA64_SEMFIX"xchg2 %0=[%1],%2" : "=r"
(result)
                                                                  ^

/usr/include/asm/system.h(270): error: asm statements not supported in
this environment
                __asm__ __volatile (IA64_SEMFIX"xchg4 %0=[%1],%2" : "=r"
(result)
                ^

/usr/include/asm/system.h(270): error: expected a ")"
                __asm__ __volatile (IA64_SEMFIX"xchg4 %0=[%1],%2" : "=r"
(result)
                                                                  ^

/usr/include/asm/system.h(275): error: asm statements not supported in
this environment
                __asm__ __volatile (IA64_SEMFIX"xchg8 %0=[%1],%2" : "=r"
(result)
                ^

/usr/include/asm/system.h(275): error: expected a ")"
                __asm__ __volatile (IA64_SEMFIX"xchg8 %0=[%1],%2" : "=r"
(result)
                                                                  ^

compilation aborted for shmem.c (code 2)

----------------------------------------------------------------------

-Manoj:)


