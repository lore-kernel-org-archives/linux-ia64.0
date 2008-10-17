From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Oct 2008 20:18:41 +0000
Subject: Re: [PATCH] ia64: use generic compat_sys_ptrace
Message-Id: <20081017201841.GA26920@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080901161918.GB16320@lst.de>
In-Reply-To: <20080901161918.GB16320@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2008 at 01:15:29PM -0700, Luck, Tony wrote:
> Lots of overlap between your patch for this and
> part 4 of Shaohua Li's utrace preparation patch
> series:
> 
> http://marc.info/?l=linux-ia64&m2172423100433&w=2
> 
> 
> I've taken Shaohua's patch.  We can work out later
> whether any bits that you did got missed.

That patch looks like it's strictly a superset of mine.  Which ins some
ways is a rather bad thing, and it's stuff that should be in a few
individual patches merged into a single large one.

But at least this should take care of the last per-arch compat ptrace
implementation.
