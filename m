From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 19 Jan 2005 22:22:56 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <200501191422.57183.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 19, 2005 2:20 pm, David Mosberger wrote:
> In my opinion, an EFI-based system should respect the
> attribute-restrictions specified in the memory-map.

That makes sense to me.  Seems like we could use a whole new arch abstraction 
for setting memory attributes (wc and uncached at the very least) on page 
ranges, but that's a much bigger task.

Jesse
