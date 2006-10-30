From: Horms <horms@verge.net.au>
Date: Mon, 30 Oct 2006 00:55:15 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061030005515.GC11243@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[ Restoring CC list ]

On Thu, Oct 26, 2006 at 11:13:07AM +0200, Christian Cotte-Barrot wrote:
> It looks like I got the same problem booting a 2.6.19-rc3 kernel
> (same thing with 2.6.19-rc1)

I just did a quick check in git, and 05e0caad3b7bd0d0fbeff980bca22f186241a501
does indeed seem to have been added between 2.6.18 and 2.6.19-rc1.

> Then I added the following patch that makes show_stack() print stacked
> registers in backtrace:
> http://www.gelato.unsw.edu.au/archives/linux-ia64/0503/13426.html

Nice patch, thanks for pointing it out to me.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

