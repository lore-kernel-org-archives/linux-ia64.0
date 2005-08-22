From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 22 Aug 2005 19:38:45 +0000
Subject: Re: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <Pine.LNX.4.62.0508221235290.7735@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 22 Aug 2005, Matthew Wilcox wrote:

> On Mon, Aug 22, 2005 at 12:20:13PM -0700, Christoph Lameter wrote:
> > We ran into the limit with the maximum number of waiters at one of our sites.
> > 
> > This patch increases the number of possible waiters from 2^15 to 2^31 by using
> > a long for the counter in struct rw_semaphore.
> 
> Why not just change the BIAS value to 0x0010000?  As long as you don't
> have more than 1024 processors trying to simultaneously acquire the same
> write lock (and if you do, you have other problems ...), this won't fail
> and gives you 2^19 waiters.

The same approach was already chosen by s390 and alpha.

Changing the bias value reduces the maximum number of waiting 
processes as you noted. Note "processes" not processors. One processor can 
have multiple processes waiting on semaphores. These are not spinlocks.


