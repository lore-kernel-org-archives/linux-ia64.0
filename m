From: Mario Smarduch <cms063@email.mot.com>
Date: Mon, 04 Nov 2002 21:07:43 +0000
Subject: Re: [Linux-ia64] linuxthread stack problem
Message-Id: <marc-linux-ia64-105590709805330@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805328@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805328@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Philip Armstrong wrote:

> All,
>
> I have run into a linuxthread problem that is caused by some (bad ?)
> assumptions on stack address usage. The problem manifests itself in the
> pthread_cleanup_push() and pthread_cleanup_pop() macros. The symptom of
> the problem is that a pthread_cancel does not execute all of the
> thread's cleanup routines if more than one routine gets pushed onto the
> cleanup stack in the same subroutine.
>
> The reason for the problem is that the pthread_cancel code that pops and
> executes the cleanup 'stack' continues using the _prev value of each
> pthread_cleanup frame until the stack address of the next frame is
> greater|less than the current one based on a #define named either
> STACK_GROWS_UP or STACK_GROWS_DOWN. I believe this is based on the
> assumption that as you  progress down|up the stack by going into or
> returning from subroutines, the stack does indeed grow down|up.
>
> While in the same subroutine, however, the ordering of the
> pthread_cleanup_buffer stack addresses as allocated by the
> pthread_cleanup_push macro is indeterminate, at least it is on our IA64
> platform.
>
> I have simplified the problem into a short test case that uses the
> bracketing and stack address allocation in the same manner that the
> pthread_cleanup_push() and pthread_cleanup_pop() macros do. In my case,
> we have STACK_GROW_DOWN defined, and as you can see the second stack
> address is actually greater than the first. The pthread_cancel routine
> would not execute the second cleanup subroutine put on the stack in this
> case becuase the address comparison (FRAME_LEFT in
> linuxthreads/cancel.c) would prohibit it.
>
> I scanned the linux-ia64 archive for any discussion on this topic and
> found none. I'm not sure if this problem is out there on any other IA64
> platforms, either. I guess you can try the test case and see for
> yourself.
>
> Test program:
>
> #include <stdio.h>
> #include <malloc.h>
>
> main(int argc, char **argv)
> {
>         printf("hello+AFw-n");
>   {
>     int x = 1;
>     printf("x = %d, &x = %x+AFw-n", x, &x);
>
>     {
>       int y = 2;
>       printf("y = %d, &y = %x+AFw-n", y, &y);
>     }
>
>   }
>         printf("goodbye+AFw-n");
>
> }
>
> My results:
>
> hello
> x = 1, &x = ffffb4e0
> y = 2, &y = ffffb4e4
> goodbye

I think that just  the way the compiler allocates locals for stacks that
grow
down. The order in which they are declared is reversed to the allocation on

the stack. On Alpha or MIPS its the opposite.

- Mario.



>
>
> --
>         Phil Armstrong       pma@sgi.com
>         Phone: 651-683-5561  VNET 233-5561
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


