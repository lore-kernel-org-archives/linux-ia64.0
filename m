From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 May 2007 12:49:58 +0000
Subject: Re: [request-for-test] [patch 0/3] [IA64] Allow DISCONTIGMEM without NUMA
Message-Id: <20070510124956.GA3746@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070510101945.495818588@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070510101945.495818588@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 10, 2007 at 12:45:48PM +0100, Christoph Hellwig wrote:
> On Thu, May 10, 2007 at 07:19:45PM +0900, Simon Horman wrote:
> > The following patches relate to allowing DISCONTIG memory to compile
> > (and hopefully work) without NUMA. I've tested that they boot, but not much
> > beyond that.
> 
> Why?  I though we wanted to use virtual mem_map and sparsemem for
> holes inside a single node?

There was a breif dicusion on linux-ia64 which I interpated as Tony
saying it was a good idea.

http://thread.gmane.org/gmane.linux.ports.ia64/16325/focus327

With regards to sparse, the current code needs most if
not all these fixes in order to use arch/ia64/mm/discontig.c.
Is the idea to rework that?

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

