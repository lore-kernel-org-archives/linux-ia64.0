From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 20 Nov 2004 03:55:10 +0000
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-Id: <20041120035510.GH2714@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com> <419D581F.2080302@yahoo.com.au> <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com> <419D5E09.20805@yahoo.com.au> <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com> <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <20041120020306.GA2714@holomorphy.com> <419EBBE0.4010303@yahoo.com.au>
In-Reply-To: <419EBBE0.4010303@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

William Lee Irwin III wrote:
>> Unprivileged triggers for full-tasklist scans are NMI oops material.

On Sat, Nov 20, 2004 at 02:37:04PM +1100, Nick Piggin wrote:
> Hang on, let's come back to this...
> We already have unprivileged do-for-each-thread triggers in the proc
> code. It's in do_task_stat, even. Rss reporting would basically just
> involve one extra addition within that loop.
> So... hmm, I can't see a problem with it.

/proc/ triggering NMI oopses was a persistent problem even before that
code was merged. I've not bothered testing it as it at best aggravates it.

And thread groups can share mm's. do_for_each_thread() won't suffice.


-- wli
