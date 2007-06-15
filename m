From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Jun 2007 20:03:08 +0000
Subject: RE: [PATCH] ia64: Scalability improvement of gettimeofday with jitter compensation
Message-Id: <617E1C2C70743745A92448908E030B2A01B3475A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0706151040180.9132@schroedinger.engr.sgi.com>
References: <466E0FA4.2040405@jp.fujitsu.com>
In-Reply-To: <466E0FA4.2040405@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

> >   ret = cmpxchg(&last_cycle, last, new);
> >   if (ret = last)
> >     return new; /* you win! */
> >   else
> >     return ret; /* you lose. ret is winner's new */
>
> Interesting solution. But there may be multiple updates of last happening. 
> Which of the winners is the real winner?

It might not matter.  Let's look at how good a guarantee an
application can expect from gettimeofday().  First of all
there may be arbitrary delays either before, or after the
kernel comes up with the "current" time since the process
could be context switched in the glibc prologue or epilogue
for the system call.  So I think that the best that an
application can expect is:

 Given two calls to gettimeofday A and B, where through some
 external syncronization it is known that call B is initiated
 after A has completed, then B shall not return a time value
 lower than that returned by A.

Now if that is the strongest ordering that an application can
expect (and I'm not completely convinced that I'm right, other
definitions gratefully accepted), then it would appear that
is is just over-engineering to worry too much about calls that
collide inside the kernel (since these don't satisfy the
"B initiated after A completes" clause of my definition).

-Tony

[For some 50 year old British humour on the subject of time,
 read: http://www.hexmaster.com/goonscripts/what_time_is_it.html ]
