From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 19 Nov 2004 03:28:41 +0000
Subject: Re: fast path for anonymous memory allocation
Message-Id: <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
 <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
 <419D5E09.20805@yahoo.com.au>
In-Reply-To: <419D5E09.20805@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Fri, 19 Nov 2004, Nick Piggin wrote:

> But you're doing it after you've set up a pte for that page you are
> clearing... I think? What's to stop another thread trying to read or
> write to it concurrently?

Nothing. If this had led to anything then we would have needed to address
this issue. The clearing had to be outside of the lock in order not to
impact the performance tests negatively.

> > If you do the clearing with the page table lock held then performance will
> > suffer.
> Yeah very much, but if you allocate and clear a "just in case" page
> _before_ taking any locks for the fault then you'd be able to go
> straight through do_anonymous_page.
>
> But yeah that has other issues like having a spare page per CPU (maybe
> not so great a loss), and having anonymous faults much more likely to
> get pages which are cache cold.

You may be able to implement that using the hot and cold lists. Have
something that runs on the lists and prezeros and preformats these pages
(idle thread?).

Set some flag to indicate that a page has been prepared and then just zing
it in if do_anymous_page finds that flag said.

But I think this may be introduce way too much complexity
into the page fault handler.
