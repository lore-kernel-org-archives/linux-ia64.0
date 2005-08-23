From: Christoph Lameter <clameter@engr.sgi.com>
Date: Tue, 23 Aug 2005 13:39:32 +0000
Subject: RE: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <Pine.LNX.4.62.0508230636090.14529@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Aug 2005, Chen, Kenneth W wrote:

> #define RWSEM_ACTIVE_MASK               0x00000fff
> #define RWSEM_WAITING_BIAS              (-0x00001000)

Correct. Thatis going to shift it the right way.

> which gives you roughly 20 bits for number of waiter, at the expense of
> reducing
> number of uncontended reader to 12 bits. Or you can do 18/14 bits
> breakdown. Will
> that work?

Maybe but this is still cutting it too close for my taste since we have 
ever increasing numbers of processors. s390 and alpha already use a 64bit 
value there and we are 64 bit as well. Lets just adopt the same approach 
to be sure that we wont run into these limitations again.
 
> By the way, you must have an app of the devil to trigger the overflow,
> at ~64K
> rwsem waiter?

Its an extreme case I agree.

The patch is okay?
