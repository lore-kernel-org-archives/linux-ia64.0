From: Jack Steiner <steiner@sgi.com>
Date: Wed, 09 May 2001 14:21:49 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.4)
Message-Id: <marc-linux-ia64-105590693005559@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Wed, 9 May 2001 08:38:42 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> FYI, The IA64 system being built by SGI has multiple
>   Jack> nodes. The clocks on different nodes are not synchronized.
> 
> This means that (a) you'll have to disable gettimeofday()
> interpolation in the kernel and (b) implement an alternate version of
> the *clock* routines in libc.  Does SN1 provides some other means to
> obtain a system-wide fine-grained timestamp?

OK, thanks. I'll add that to our (never ending) worklist.

Up to this point, we were not aware that we would have to make any 
changes in any library routines.  I have not looked at the libc clock 
routine, but it sounds like I should take a look...


BTW, The SN platform does have a hi-res synchronized clock that can be
mmapped & read from user space. The clock is located in the "chipset"
and is synchronized across all nodes/FSBs.



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


