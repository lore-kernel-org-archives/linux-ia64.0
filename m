From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 22 Nov 2004 23:19:36 +0000
Subject: Re: deferred rss update instead of sloppy rss
Message-Id: <Pine.LNX.4.58.0411221517090.24333@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <20041122141148.1e6ef125.akpm@osdl.org> <Pine.LNX.4.58.0411221408540.22895@schroedinger.engr.sgi.com>
 <20041122144507.484a7627.akpm@osdl.org> <Pine.LNX.4.58.0411221444410.22895@schroedinger.engr.sgi.com>
 <20041122151628.77ab87ca.akpm@osdl.org>
In-Reply-To: <20041122151628.77ab87ca.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 22 Nov 2004, Andrew Morton wrote:

> > The timer tick occurs every 1 ms.
>
> That only works if the task happens to have the CPU when the timer tick
> occurs.  There remains no theoretical upper bound to the error in mm->rss,
> and that's very easy to fix.

Page fault intensive programs typically hog the cpu. But you are in
principle right.

The "easy fix" that you propose is to add additional logic to some very
hot code paths. Then we are probably better off with another approach.

