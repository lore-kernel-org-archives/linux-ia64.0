From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 10 Jan 2005 17:16:05 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <Pine.LNX.4.58.0501100915200.19135@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>

On Sat, 8 Jan 2005, Hugh Dickins wrote:

> Christoph, a late comment: doesn't this effectively replace
> do_anonymous_page's clear_user_highpage by clear_highpage, which would
> be a bad idea (inefficient? or corrupting?) on those few architectures
> which actually do something with that user addr?

Yes. Right my ia64 centric vision got me again. Thanks for all the other
patches that were posted. I hope this is now all cleared up?

