From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 19 Jan 2001 01:43:44 +0000
Subject: Re: [Linux-ia64] CONFIG_IA64_PAGE_SIZE
Message-Id: <marc-linux-ia64-105590693005087@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005077@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005077@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 18 Jan 2001 12:43:06 -0800, Rich Altmaier <richa@engr.sgi.com> said:

  Rich> However be aware of one significant downside to larger page
  Rich> sizes, for workloads involving a large number of small
  Rich> processes.  Suppose you fire up 1000 processes on a system,
  Rich> then the additional physical memory consumption is
  Rich> significant.  I actually don't know the correct calculation
  Rich> but guesstimate that per-process data structures which
  Rich> increase in size include kernel stack, task struct, each
  Rich> shared lib data segment, user data segment.  If the pagesize
  Rich> is increased from 4K to 64K, then 4 such elements yield
  Rich> 60K*4*1000 processes = 240Mbyte.

The minimum task size was an important consideration in the design of
IA-64 Linux.  As Don pointed out, the process data structure is at
least 32KB no matter what page size is in use (to avoid stack
overflow), so this really makes a difference only when the page size
is 64KB.

However, the real biggie are the page tables.  Even the smallest task
needs at the least three page table pages, so here the page size can
have a big impact.

  Rich> Some customers do complain about this (and I tell them to buy
  Rich> more memory and enjoy the performance).

Good answer! ;-)

	--david

