From: JinShan Xiong <jinshan.xiong@gmail.com>
Date: Fri, 28 Jan 2005 04:05:43 +0000
Subject: Re: About intercepting linux system call
Message-Id: <b3b26beb050127200512f148d6@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <b3b26beb05012620543066d40@mail.gmail.com>
In-Reply-To: <b3b26beb05012620543066d40@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

Thanks for your help. I can intercept the time function now.

But the kernel crashed when I tried to de-install the module. I
declared the old_time as:

static unsigned long old_time;

and in init_module:

old_time = sys_call_table[__NR_gettimeofday - 1024];
....

and then in cleanup_module:

sys_call_table[__NR_gettimeofday - 1024] = old_time.

Why can't it work?

And I tried to declare the old_time as a function pointer and restore
the syscall entry like:

sys_call_table[__NR_gettimeofday - 1024] = ((struct fptr *)&old_time)->ip;

it can't work too.

Regards,
JinShan


On Thu, 27 Jan 2005 18:10:36 -0800, David Mosberger
<davidm@napali.hpl.hp.com> wrote:
> >>>>> On Fri, 28 Jan 2005 10:04:33 +0800, JinShan Xiong <jinshan.xiong@gmail.com> said:
> 
>   JinShan> Hi David, I don't know how to use the stub code, I have
>   JinShan> tried to copy it to overload sys_gettimeofday(), like this,
> 
>   JinShan>  memcpy(sys_call_table[__NR_gettimeofday - 1024],
>   JinShan> new_time_stub, 32),
> 
>   JinShan> it crashed the kenrel also.
> 
>   JinShan> Please help me!
> 
> sys_call_table[__NR_gettimeofday - 1024] would have to be set to the
> entry-point of new_time_stub.  If you declare new_time_stub as a
> function, you'd have to do this like so:
> 
>         extern void new_time_stub (whatever...);
>         struct fptr { void *ip, void *gp };
> 
>         sys_call_table[__NR_gettimeofday - 1024] >                 ((struct fptr *) &new_time_stub)->ip;
> 
>   --david
> 
>
