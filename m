From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 28 Aug 2004 00:19:11 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support
Message-Id: <Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
 <20040815165827.0c0c8844.davem@redhat.com> <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
 <20040815185644.24ecb247.davem@redhat.com> <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
 <20040816143903.GY11200@holomorphy.com>
 <B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
 <B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
 <B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
 <Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
 <20040827233602.GB1024@wotan.suse.de>
In-Reply-To: <20040827233602.GB1024@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@redhat.com>, raybry@sgi.com, ak@muc.de, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

That is still 2^(32+12) = 2^44 = 16TB.

On Sat, 28 Aug 2004, Andi Kleen wrote:

> > Index: linux-2.6.9-rc1/include/linux/sched.h
> > =================================> > --- linux-2.6.9-rc1.orig/include/linux/sched.h	2004-08-25 10:50:12.534021000 -0700
> > +++ linux-2.6.9-rc1/include/linux/sched.h	2004-08-27 12:14:09.564008624 -0700
> > @@ -197,9 +197,10 @@
> >  	pgd_t * pgd;
> >  	atomic_t mm_users;			/* How many users with user space? */
> >  	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
> > +	atomic_t mm_rss;			/* Number of pages used by this mm struct */
>
> atomic_t is normally 32bit, even on a 64bit arch.  This will limit the max
> memory size per process to 2^(32+PAGE_SHIFT). I don't think that's a good idea.
>
> On some architectures it used to be 24bit only even, but I think that
> has been fixed.
>
> I think you need atomic64_t
>
> -Andi
>
