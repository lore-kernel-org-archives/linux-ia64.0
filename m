From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 08 Mar 2002 07:50:15 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905238@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David Mosberger schrieb:

> >>>>> On Thu, 28 Feb 2002 09:06:54 +0100, Christian Hildner <christian.hildner@hob.de> said:
>
>   Christian> David Could you please send me your test program to
>   Christian> verify this. Since I haven't fixed the storage in my test
>   Christian> prog maybe there are additional page faults.
>
> Well, the copyright is almost longer than the program itself, but here
> you go.  It was just a quick hack, so treat with care...  If you do
> make enhancements, I'd be interested, though.
>
>         --david
>

David,

I tried with my different program and it's just as before. Without TLB miss ~10 cycles, TLB miss
and VHPT ~750 cycles and TLB miss with VHPT disabled ~900 cycles. I don't know what wrong. Is it
the test prog or the processor. In the IVT there are only some few instructions to do. The intel
manual says that there is a variable latency for the instruction itc.

Could you please try with my test program to verify what I found (compile with -O). The pointer
increment is half the page size, so TLB hit and TLB miss are changing.

Christian

#define KB 1024
#define INCREMENT 4096
#define MEMSIZE (128*KB)

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/resource.h>

inline long get_ticks(void)
{
    long ticks;

    asm volatile ("
        ;;
        mov %0=ar.itc
        ;;
        \n"
        :"=r"(ticks)
        :);
    return(ticks);
}


int main(void)
{

    char *stg;
    char *current;
    char *end;
    char val;
    long t1,t2,tdiff;
    struct rlimit rlim;

    printf("tlbtest starting ...\n");
    rlim.rlim_cur = MEMSIZE;
    rlim.rlim_max = MEMSIZE;
    if (setrlimit(RLIMIT_MEMLOCK, &rlim) != 0) {
        printf("setrlimit() failed\n");
        return(-1);
    }
    stg = (char *)malloc(MEMSIZE);
    if (stg = NULL) {
        printf("memory not available\n");
        return(-1);
    }
    printf("stg = %p\n", (void *)stg);
    if (!mlock((void *)stg, MEMSIZE)) {
        printf("mlock() failed\n");
        free(stg);
        return(-1);
    }
    end = stg + MEMSIZE;
    current = (char *)stg;
    while (current < end) {
        t1 = get_ticks();
        val = *current;
        t2 = get_ticks();
        printf("ticks1 %ld\n", t2-t1);
        current += INCREMENT;
    };
    printf("ignore this value val = %d\n", (int)val);
    free(stg);
    return(0);
}

typical output:
VPHT disabled                VHPT enabled

tlbtest starting ...         tlbtest starting ...
stg = 0x20000000002a6010     stg = 0x20000000002a6010
ticks1 11                    ticks1 13
ticks1 36                    ticks1 16
ticks1 1349                  ticks1 1135
ticks1 187                   ticks1 191
ticks1 928                   ticks1 751
ticks1 10                    ticks1 10
ticks1 933                   ticks1 778
ticks1 10                    ticks1 10
ticks1 946                   ticks1 725
ticks1 21                    ticks1 10
ticks1 1101                  ticks1 912
ticks1 10                    ticks1 10
ticks1 941                   ticks1 755
ticks1 10                    ticks1 10
ticks1 939                   ticks1 740
ticks1 10                    ticks1 10
ticks1 966                   ticks1 749
ticks1 10                    ticks1 10
ticks1 954                   ticks1 748
ticks1 21                    ticks1 10
ticks1 920                   ticks1 734
ticks1 10                    ticks1 21
ticks1 936                   ticks1 765
ticks1 21                    ticks1 21
ticks1 945                   ticks1 733
ticks1 10                    ticks1 10
ticks1 1113                  ticks1 921
ticks1 21                    ticks1 10
ticks1 921                   ticks1 754
ticks1 10                    ticks1 10
ticks1 903                   ticks1 719
ticks1 10                    ticks1 10
ignore this value val = 0    ignore this value val = 0


