From: Ben Woodard <woodard@redhat.com>
Date: Tue, 03 Feb 2004 00:36:17 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <1075768577.9273.137.camel@xenophanes>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2004-02-01 at 23:00, Keith Owens wrote:
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

Amen brother!
Seriously, ever since I started looking into the MCA/salinfo stuff for
LLNL, I've felt like the code really needed some big overhauls. However,
I didn't feel like I had enough experience with the various oddities of
the hardware to feel comfortable really taking a heavy hand to it.

Jim Garlick and I have both been trying to make the smallest changes
possible to fix the problems we have been seeing. We haven't really had
a chance to look through your patches in detail much less try that out
but we should be able to get you some feedback regarding it by the end
of the week. From the quick glance that I've given it so far it looks
like it is a step in the right direction.

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
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

