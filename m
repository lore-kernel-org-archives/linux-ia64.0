From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 19 Nov 2004 02:19:11 +0000
Subject: Re: fast path for anonymous memory allocation
Message-Id: <419D581F.2080302@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> This patch conflicts with the page fault scalability patch but I could not
> leave this stone unturned. No significant performance increases so
> this is just for the record in case someone else gets the same wild idea.
> 

I had a similar wild idea. Mine was to just make sure we have a spare
per-CPU page ready before taking any locks.

Ahh, you're doing clear_user_highpage after the pte is already set up?
Won't that be racy? I guess that would be an advantage of my approach,
the clear_user_highpage can be done first (although that is more likely
to be wasteful of cache).
