From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 08 Nov 2004 17:01:27 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.58.0411080858400.8212@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Mon, 8 Nov 2004, Hugh Dickins wrote:

> > Maintaining these counters requires locking which interferes with Nick's
> > and my attempts to parallelize the vm.
>
> Aren't you rather overestimating the importance of one single,
> ideally atomic, increment per page fault?

We would need to investigate that in detail. What we know is that if
multiple cpus do atomic increments with an additional spinlock/unlock etc
as done today then we do have a significant performance impact due to
exclusive cache lines oscillating between cpus.

> It's great news if this is really the major scalability issue facing Linux.

Not sure. This may just be a part of it.
