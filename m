From: Russ Anderson <rja@sgi.com>
Date: Wed, 01 Aug 2007 20:34:01 +0000
Subject: Re: ACPI: Uninitialized spinlocks & Unable to dump stack
Message-Id: <200708012034.l71KY1fa140769726@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> 
> On Wed, 1 Aug 2007, Russ Anderson wrote:
> 
> > The bad news is the kernel boot on SN2 still hangs in udevsettle.
> 
> We found two problems with clocks that account for the udevsettle hang.
> 
> Kenji's patch is still necessary to get rid of the spinlock problems.

Thanks Christoph & Kenji!

With those two patches the kernel boots on SN2.
Life is good.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
