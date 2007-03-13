From: David Miller <davem@davemloft.net>
Date: Tue, 13 Mar 2007 02:26:16 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070312.192616.63128242.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
	<20070312.155157.74747634.davem@davemloft.net>
	<17909.62028.117035.287313@cargo.ozlabs.ibm.com>
In-Reply-To: <17909.62028.117035.287313@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

From: Paul Mackerras <paulus@samba.org>
Date: Tue, 13 Mar 2007 11:37:32 +1100

> David Miller writes:
> 
> > I ported this to sparc64 as per the patch below, tested on
> > UP SunBlade1500 and 24 cpu Niagara T1000.
> 
> Did you see any performance improvement?  We used to have quicklists
> on ppc, but I remain to be convinced that they actually help.

It shaved about 3 or 4 seconds consistently off of my kernel
build on Niagara which usually clocks in just over 4 minutes
on this 24 thread machine.

> Also, I didn't understand why we have to do quicklists to take
> advantage of the fact that the pages are in a pristine state when they
> are freed.  I thought the whole point of the slab allocator was to be
> able to take advantage of that...

He just wants to side-step the issue in SLUB, which arguably
is an attempt to simplify SLUB at the expense of functionality.

I don't agree with that, but I'm merely preemptively testing his
patches and porting them to sparc64 so it does not break when/if his
code is merged in.  After being bitten by stuff like this in the past,
I've decided to become more proactive :)
