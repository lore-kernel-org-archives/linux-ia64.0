From: Colin Ngam <cngam@sgi.com>
Date: Sat, 18 Oct 2003 01:17:33 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106644157423998@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641220628729@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641220628729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Fri, 17 Oct 2003 18:47:51 +0100, Christoph Hellwig <hch@infradead.org> said:
>
>   Christoph> On Fri, Oct 17, 2003 at 10:31:27AM -0700, David Mosberger
>   Christoph> wrote:
>   >> So what should be done about these SN2 cleanups?  I don't want to
>   >> accept dozens of small "fixes" (which really are mostly cleanups)
>   >> as that would defeat the idea of the code-fixes-only decree.  On
>   >> the other hand, I really would like to see the SN2 code cleaned
>   >> up so we actually have a sane base to do bug fixes on top of.
>
>   Christoph> What about letting the SGI folks creeate a
>   Christoph> sn-cleanups-2.6 BK tree and let them deal with Linus
>   Christoph> themselves with your below blanket approval?
>
> That's what I was suggesting (apart from patch vs bk; I don't care
> about the mechanism of getting the updates into Linus tree; I just
> don't want to be stuck with a large SN2 update which may or may not be
> accepted by Linus/Andrew).
>
>         --david

Hi David,

On top of cleanup, we will also have new IO hardware support for 2.6 that
we are doing on 2.4 and shipping with 2.4 kernels.  I do like the idea of a single
mod for 2.6 that covers:

    1.  Christoph's various patches.
    2.  Our very own cleanup effort that has been in progress.
    3.  New SGI IO Hardware support.

It does not matter to me if you want us to wait until this code-fixes-only
period is over.  We will be doing all our regression on 2.4 and when we
merge over to 2.6, we will also do our regression tests there too.  None of these
changes will have any effect on any other platform except to ensure that
Generic builds and boots on other Platforms(including SGI).

We are currently adjusting our development effort to better update and
refresh the latest levels of Linux.

Thanks.

colin

