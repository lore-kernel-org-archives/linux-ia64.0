From: Dan Pop <Dan.Pop@cern.ch>
Date: Wed, 14 Nov 2001 16:49:22 +0000
Subject: Re: [Linux-ia64] correct seg fault address on ia-64??
Message-Id: <marc-linux-ia64-105590698805509@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805506@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805506@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 14 Nov 2001, Pereira, D LailaX E wrote:

>   x=(int*)malloc(2*page_size);
> 
>  /* Align to a multiple of page_size, assumed to be a power of two */
>   x = (int *)((long)(((int) (long)x + page_size-1) & ~(page_size-1)));
                        ^^^^^
This conversion is the WRONG thing: you are losing significant bits
from the 64-bit pointer's value!

>   printf("Address:  %x\n",x );

And this is the wrong way of displaying a pointer, which is not a
32-bit entity and definitely not an unsigned int.  The right way of
doing it is:

    printf("Address:  %p\n", (void *)x);

> .............
> However , when I ran the program thru gdb, I got the following:
> Reading symbols from a.out...done.
> (gdb) run ex3.c
> ......
> Pagesize : 16384 ,PID(471
> Address:  4000
> Page protection : NONE : try reading the page
>  segv should arise now ...
> 
> Program received signal SIGSEGV, Segmentation fault.
> 0x40000000000010e0 in main ()
> (gdb) where 
> #0  0x40000000000010e0 in main ()
> #1  0x20000000000906b0 in __libc_start_main (
>     main=0x40000000000013e8 <_fini+408>, argc=2, 
> ubp_av=0x80000fffffffb848, 
>     init=0x40000000000013b8 <_fini+360>, 
>     fini=0x200000000003db30 <_dl_debug_mask>, 
>     rtld_fini=0x20000000002581c8 <_dl_get_origin+632>, 
>     stack_end=0x80000fffffffb840) at ../sysdeps/generic/libc-start.c:129
> #2  0x40000000000010b0 in main ()
> (gdb)....
> 
> 
> So thru, gdb the seg fault address is "0x40000000000010e0" , is my
> interpretation right ?? 
> Why is that when I run the program on itanium , I get the address as "4000"
> and thru gdb as " 0x40000000000010e0". What is wrong?? Please let me know.

You're confusing data addresses and code addresses.  You're displaying
the value of a pointer, which is a (badly formed) data address, while
gdb is displaying the address of the instruction that generated the
fault, i.e. a code address.

Dan


