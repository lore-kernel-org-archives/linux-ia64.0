From: Russ Anderson <rja@sgi.com>
Date: Mon, 23 Jul 2007 21:03:38 +0000
Subject: Re: Linus' tree broken?
Message-Id: <200707232103.l6NL3cBR133650413@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> > I heard from John Keller that he had problems too. What kind of
> > userland are you running? I've seen hanging around udev.
> 
> I took 2.6.23-rc1 over to a Hitachi box running FC7 userspace.
> It booted just fine there.
> 
> Maybe we broke SN2?

Neither Linus' tree (2.6.23-rc1) nor Tony's test tree (2.6.22) boot on the 
three SN2 systems I tried booting on (SLES 10 roots).  Tony's test tree
from ~3 weeks ago does boot.

The last boot message is "Starting udevd".  

The cpu LEDs are toggling between 0 & 1 "Kernel: CPU idle".
It doesn't panic.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
