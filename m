From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Wed, 27 Jun 2001 21:57:56 +0000
Subject: RE: [Linux-ia64] Re: pthread_mutex_lock sometimes fails on Linux
Message-Id: <marc-linux-ia64-105590693005792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005788@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005788@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The problem I previously reported occurs on a 2.4.5 kernel built from stock
source code (No Alan Cox patches, only the ia64 patch).

I slightly misstated the problem.  Here is what actually happens:
Four threads have entered a barrier (my own C code).  Within the barrier,
they call pthread_mutex_lock and increment a counter while holding the lock.
Three threads are waiting on the counter, whose value is three, to go to
four.  The fourth CPU is looping in the kernel in cpu_idle.  I don't know
how it got there, but probably it has something to do with calling
pthread_mutex_lock.

As I said, if anyone wants to investigate this I will provide a test case.

David

> -----Original Message-----
> From: Robboy, David G [mailto:david.g.robboy@intel.com]
> Sent: Wednesday, June 27, 2001 11:30 AM
> To: 'Bill Nottingham'; 'linux-ia64@linuxia64.org'
> Subject: RE: [Linux-ia64] Re: pthread_mutex_lock sometimes fails on
> Linux 2.4.5
> 
> 
> > Stock 2.4.5 or something else?
> 
> Something else.  We have features of our own in the kernel for system
> validation.  I guess I should try it on a stock kernel.
> 
> David
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


