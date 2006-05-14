From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 14 May 2006 21:37:42 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <1147642663.2729.8.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147633985.2551.14.camel@shinybook.infradead.org>
In-Reply-To: <1147633985.2551.14.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2006-05-14 at 23:13 +0200, Andreas Schwab wrote:
> > Hm, same applies here as to the last one. The __KERNEL__ ifdef applies
> > to the whole crap around PAGE_SHIFT _and_ PAGE_SIZE, at least. 
> 
> Userspace should be using getpagesize() anyway.

Yes. That's why I say all the PAGE_SIZE crap should be in #ifdef
__KERNEL__. 

I also suspect a lot of the _rest_ of that file shouldn't be visible
either. What's in there that we actually _need_ to export?

-- 
dwmw2

