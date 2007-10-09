From: Alex Chiang <achiang@hp.com>
Date: Tue, 09 Oct 2007 13:25:45 +0000
Subject: Re: [PATCH] ia64: /proc/cpuinfo "physical id" field cleanups
Message-Id: <20071009132545.GC7493@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070928010850.GG16444@ldl.fc.hp.com>
In-Reply-To: <20070928010850.GG16444@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Thanks for looking at this.

> >	- expose "physical id" field, even on CPUs that are not
> >	  multi-core / multi-threaded. Now we know what sockets
> >	  Madisons live in too.
> 
> This sounds like a good idea.  But this patch didn't work for me
> to achieve that on my HP 2620.  /proc/cpuinfo with this patch looks
> like this:
> 
> processor  : 0
>  ...
> physical id: 4294967295
> 
> processor  : 1
>  ...
> physical id: 4294967295
> 
> 
> So both my Madison cpus are apparently sharing the same socket!  That
> big decimal number is just "-1" printed as an unsigned.

I spent some time looking at this and also talked with our
low-end firmware guys, and think I understand what's going on
now.

First, on HP low-end platforms, like your rx2620,
SAL_PHYSICAL_ID_INFO is hard coded to return 0. I missed this
because I tested on low-end and high-end with Montes, and on
high-end with Madisons. I must have missed low-end Madison based
platforms. :(

Based on that information, I will have to rethink my approach.

Second, SAL_PHYSICAL_ID_INFO did not show up until SAL 3.2, which
I think is why you got -1. On my rx2620, I have a relatively
modern firmware which does have the SAL call, and I get 0 for
each physical id (with Madisons).

In identify_cpu(), we initialize c->socket_id to -1 because we
expect that value to get overwritten later, in identify_siblings().

If you look at my patch, identify_siblings() calls
ia64_sal_physical_id_info(), and then returns if we get a
failure.

You should have seen this printk:

	printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);

Can you verify that you saw that in your dmesg? I think the
status should be -1, due to not-implemented.

Thanks.

/ac

