From: Robin Holt <holt@sgi.com>
Date: Wed, 15 Sep 2004 11:04:51 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <20040915110451.GA31261@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 15, 2004 at 01:23:55AM -0700, David Mosberger wrote:
> >>>>> On Tue, 14 Sep 2004 10:16:29 -0500, Robin Holt <holt@sgi.com> said:
> 
>   Robin> I would like to start with the general, what are we trying to
>   Robin> solve?  I can not think of a single reason aside from the
>   Robin> previously discussed min state area for the kernel to ever
>   Robin> need to work with memory uncached.
> 
> Uh, what about device drivers that want to map physical memory with
> write-combine?  Isn't that effectively what your fetchop driver does?

That is exactly what it does, but I was wondering if there are other
examples of drivers that do this.  If not, I would still like to
push for doing the minimum necessary to keep from designing something
that has no users.

> 
>   Robin> Assuming there is no reason, can we pare this discussion back
>   Robin> to a page based allocator?  That would be much simpler to
>   Robin> work with and would not need to recombine fragments.
> 
> Quite possibly.  It certainly seems reasonable to start that way.
> 
> 	--david
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
