From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 04 Feb 2004 07:18:22 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <022001c3eaef$12a6caf0$a8647c0a@seto>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nice patch :-)

I am trying to make a patch and just worried about the race of printk calls.
My temporary fix was that it simply makes all prfunk in mca.c to nop by config.
However, of course, I feel better if such obsolete codes were vanished completely.

I'll change the base of my prototype of OS MCA handler to the one that patched all of
your drastic clean up patches.

BTW, could you port these patches to 2.6.x, Keith?


----- Original Message ----- 
From: "Keith Owens" <kaos@sgi.com>

> mca.c has potential deadlocks on printk() for MCA and INIT records,
> they are not irq safe.
> 
> There is a lot of crud in mca.c, with obsolete printing code, unused
> declarations, functions and data that are global when they should be
> static, functions and data that are not used or are only set to 0,
> function returns that are tested but are always 0.  In addition the
> code is disordered, requiring forward declarations and scattering
> related functions to different parts of the file.  All of which make it
> awkward to follow the code.
> 
> The following 5 patches do :-
> 
> 1 Avoid deadlock when using printk() for MCA and INIT records.
> 2 Delete all record printing code, moved to salinfo_decode in user space.
> 3 Mark variables and functions static where possible.
> 4 Delete dead variables and functions.
> 5 Reorder to remove the need for forward declarations and to consolidate
>   related code.
> 
> Altogether they shrink mca.c from 2420 to 1322 lines and make it much
> more readable.
> 
> The only functional change is the removal of any attempt to print the
> CMC/CPE/MCA/INIT record contents in the kernel.  Now we just get one
> line to say that a record has been detected, except for MCA which
> prints nothing at all.


Thanks,

H.Seto
