From: Robin Holt <holt@sgi.com>
Date: Tue, 15 Feb 2005 20:08:56 +0000
Subject: Re: [PATCH] Convert pgtable cache to slab
Message-Id: <20050215200856.GG24401@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1wtxnprkq.fsf@wilson.mkp.net>
In-Reply-To: <yq1wtxnprkq.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 15, 2005 at 12:03:22PM -0800, David Mosberger wrote:
> >>>>> On Tue, 15 Feb 2005 13:59:45 -0600, Robin Holt <holt@sgi.com> said:
> 
>   >>  I certainly don't want to switch my machines to 4-levels.  There
>   >> is zero need for that on the machines I use, so why pay the
>   >> overhead of an extra level?
> 
>   Robin> I missed the why the extra level question.  That part is
>   Robin> motivated by some large MPI jobs need a fourth level to get a
>   Robin> large enough single mapping to cover their entire dataset.
>   Robin> We have already tripped this limitation for a couple of our
>   Robin> really large customers.
> 
> What I'm saying is that the default probably should stay at 3-levels.
> Optimizing ia64 linux _just_ for "really large customers" would be
> a bad direction to go in.

I agree.  What I am asking is if we turn on the 4th level of page tables,
does anybody have an objection to 4/16k levels as opposed to 3/PAGE_SIZE
plus a 4th cleanup to cover the entire address space?

Thanks,
Robin
