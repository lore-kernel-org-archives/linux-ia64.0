From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 21:59:13 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405121459.13177.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, May 12, 2004 2:54 pm, David Mosberger wrote:
> I just don't see a lot of demand for this kind of feature at this
> point, so why bloat the kernel?  Plus the solution so far seems rather
> incomplete and fragile.  I suggest to play with this in a separate
> tree and if users start to really like the patch and can't live
> without it, well, I'm sure I'll hear about it.

Sure, ok.  I'll see how useful it is in real world situations (e.g. our gfx 
folks have been wanting this for awhile) and come back when I have compelling 
evidence of its utility.

Thanks,
Jesse
