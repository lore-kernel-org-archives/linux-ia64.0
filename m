From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Thu, 15 Mar 2007 15:57:28 +0000
Subject: Re: [BUGFIX][PATCH] fixing placement of register stack under ulimit -s
Message-Id: <ed5aea430703150857i4c60dbfdrd5c871235815e5da@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070315171743.e85b8405.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070315171743.e85b8405.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>

But aren't you going to be limited to less than a page worth of
register-backing store even with your patch applied because the
backing store will end up overflowing the memory stack?

  --david

On 3/15/07, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch fixes ia64's bug in ulimit -s handling. against 2.6.21-rc3.
>
> At first,the address of register stack is defined by this
> = ia64_set_rbs_bot()
> unsigned long stack_size = current->signal->rlim[RLIMIT_STACK].rlim_max & -16;
>
>         if (stack_size > MAX_USER_STACK_SIZE)
>                 stack_size = MAX_USER_STACK_SIZE;
>         current->thread.rbs_bot = STACK_TOP - stack_size;
> }
> =
> default rlim[RLIMIT_STACK].rlim_max is very big.
>
> If ulimit -s is used, rlim_max can be small. As a result, rbs_bot can be
> very high address. Because of stack-address-randomize, there is a case that
> "regiter stack" is placed in the higher address than "memory stack".
> = example...
> [kamezawa@drpq linux-2.6.21-rc2]$ ulimit -s
> 8192
> [kamezawa@drpq linux-2.6.21-rc2]$ cat /proc/self/maps
> 00000000-00004000 r--p 00000000 00:00 0
> 2000000000000000-2000000000038000 r-xp 00000000 08:02 5991525            /lib/ld-2.5.so
> 2000000000044000-2000000000050000 rw-p 00034000 08:02 5991525            /lib/ld-2.5.so
> 2000000000064000-20000000002c8000 r-xp 00000000 08:02 5990699            /lib/libc-2.5.so
> 20000000002c8000-20000000002d4000 ---p 00264000 08:02 5990699            /lib/libc-2.5.so
> 20000000002d4000-20000000002e0000 rw-p 00260000 08:02 5990699            /lib/libc-2.5.so
> 20000000002e0000-20000000002ec000 rw-p 20000000002e0000 00:00 0
> 20000000002ec000-2000000003a24000 r--p 00000000 08:02 9472842            /usr/lib/locale/locale-archive
> 4000000000000000-4000000000008000 r-xp 00000000 08:02 4157490            /bin/cat
> 6000000000004000-600000000000c000 rw-p 00004000 08:02 4157490            /bin/cat
> 600000000000c000-6000000000030000 rw-p 600000000000c000 00:00 0          [heap]
> 60000fffff5f4000-60000fffff648000 rw-p 60000fffff5f4000 00:00 0          [stack]
> 60000fffff7fc000-60000fffff800000 rw-p 60000fffff7fc000 00:00 0          (*)
> a000000000000000-a000000000020000 ---p 00000000 00:00 0                  [vdso]
> (*) is register stack.
> =
> This register-stack/memory-stack upside down is not expected.
> Current ia64 page fault handler doesn't handle this case. In this case,
> register stack expansion causes SEGV.
> This means that the user program can use only 1 page for its register stack.
>
> This patch fixes the above case by moving register stack to suitable place.
> Note) fixing page fault handler seems to be another way...but a bit complicated.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: linux-2.6.21-rc3/arch/ia64/mm/init.c
> =================================> --- linux-2.6.21-rc3.orig/arch/ia64/mm/init.c
> +++ linux-2.6.21-rc3/arch/ia64/mm/init.c
> @@ -155,7 +155,7 @@ ia64_set_rbs_bot (void)
>
>         if (stack_size > MAX_USER_STACK_SIZE)
>                 stack_size = MAX_USER_STACK_SIZE;
> -       current->thread.rbs_bot = STACK_TOP - stack_size;
> +       current->thread.rbs_bot = PAGE_ALIGN(current->mm->start_stack - stack_size);
>  }
>
>  /*
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
