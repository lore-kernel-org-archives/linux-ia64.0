From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Wed, 27 Sep 2000 23:54:58 +0000
Subject: Re: [Linux-ia64] [PATCH] ivt.S
Message-Id: <marc-linux-ia64-105590678205526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I don't see why that would be necessary.  Perhaps you misunderstood
> how tbit.nc.unc works?

Thanks, not anymore. :-)

> Can you try the attached patch (it's relative to the original
> version)?

I booted this UP and SMP and everything seems okay.

However, the patch would not apply cleanly though, due to:

>  #ifdef CONFIG_DISABLE_VHPT
>  itlb_fault:
>  #endif

and a similar #ifdef in the dtlb case.

[This code isn't in the last patch based on test8 that I am aware of (0913?)]

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com



