From: Hugh Dickins <hugh@veritas.com>
Date: Mon, 08 Nov 2004 16:56:49 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <Pine.LNX.4.44.0411081649450.1433-100000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0411080819260.8158@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Mon, 8 Nov 2004, Christoph Lameter wrote:
> 
> Removing realtime statistics would remove lots of code from the vm.

Remove lots of code?  Adding lots nastier.

> Maintaining these counters requires locking which interferes with Nick's
> and my attempts to parallelize the vm.

Aren't you rather overestimating the importance of one single,
ideally atomic, increment per page fault?

It's great news if this is really the major scalability issue facing Linux.

Hugh

