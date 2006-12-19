From: Horms <horms@verge.net.au>
Date: Tue, 19 Dec 2006 00:28:00 +0000
Subject: Re: 05e0caad3b7bd0d0fbeff980bca22f186241a501 breaks ia64 kdump
Message-Id: <20061219002758.GA1453@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061026075951.GA30910@verge.net.au>
In-Reply-To: <20061026075951.GA30910@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 18, 2006 at 02:52:44PM +0000, Mel Gorman wrote:
> On (12/12/06 18:10), Horms didst pronounce:

[snip]

> > Now that ia64 kexec/kdump has been merged into Linus tree this
> > really ought to be fixed. What is the best way forward?
> > 
> 
> Sorry for the delay in responding. I was ill all of last week and offline as
> a result. First, can you confirm the problem still exist? Assuming it does,
> does Bob's patch fix it? A compile-tested rebase against 2.6.20-rc1-mm1 of
> the patch is posted below for your convenience. I don'y have access to an
> ia64 machine right now to boot test it.

Hi Mel,

I'll run some tests with the new version of the patch that
you posted (below but snipped) and get back to you ASAP.

[snip]

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

