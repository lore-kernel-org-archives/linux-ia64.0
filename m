From: Matthew Wilcox <willy@debian.org>
Date: Sun, 28 Mar 2004 19:23:57 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <20040328192357.GC26179@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 26, 2004 at 04:14:13PM -0800, Chen, Kenneth W wrote:
> This question is a bit too broad, lock contention highly depends on workload.

Surely.

> For example, I'm doing direct I/O on bunch of block devices, and the dev nodes
> sit on reiserfs, this contention shows up:
> 
>  79.7% 91.2%   18us(1415us)  449us( 760ms)(57.9%)   2970234  8.8% 91.2%    0%  kernel_flag
>  0.00% 92.3%  5.8us(  35us)  689us(  58ms)(0.01%)       298  7.7% 92.3%    0%    __break_lease+0x80

I'm not familiar with this output; I'm assuming this means __break_lease()
is a major contributor to the amount that kernel_flag (ie the BKL)
is locked?  That's interesting; I assume you're using Samba as part of
your workload since it's the only major user of leases that I'm aware of.
Hmm.. seems to me we should move time_out_leases() down 5 lines to minimise
the amount of time we spend with the BKL held if there's a non-lease lock
held on the file.

I wish we'd managed to get the file locking code BKL-free during 2.5 but
it just didn't happen ;-(

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
