From: Russ Anderson <rja@sgi.com>
Date: Tue, 24 Jul 2007 23:21:11 +0000
Subject: Re: Linus' tree broken?
Message-Id: <200707242321.l6ONLBSw136203866@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> Tony Luck wrote:
> > 
> > Maybe we broke SN2?
> 
> Neither Linus' tree (2.6.23-rc1) nor Tony's test tree (2.6.22) boot on the 
> three SN2 systems I tried booting on (SLES 10 roots).  Tony's test tree
> from ~3 weeks ago does boot.
> 
> The last boot message is "Starting udevd".  

More specificly, it hangs in /sbin/udevsettle .


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
