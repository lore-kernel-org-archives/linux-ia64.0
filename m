From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 24 Nov 2003 20:00:09 +0000
Subject: RE: weird speed problem
Message-Id: <marc-linux-ia64-106970446625466@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106957761119369@msgid-missing>
In-Reply-To: <marc-linux-ia64-106957761119369@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> One _potential_ reason why it ran fast one time, and slow on 
> other runs
> is the lack of page colouring in Linux.  If the working set 
> of your test
> program is some large percentage of the cache size, then you 
> can hit this
> on any architecture, not just ia64.

Following up to myself (in response to private e-mail requesting
clarification).

You may be able to determine whether this is your problem
by using Stephane's "pfmon" tool to count cache misses at
various levels of the cache hierarchy, and comparing these
numbers from run to run.  If you see wildly varying numbers,
and your system is idle apart from the test program, then
lack of cache colouring is probably the issue.

You may be able to workaround the lack of cache colouring by
using hugetlbfs to allocate memory, since you are guaranteed
to get contiguous physical memory that will line up neatly
in your cache.  Though this may be overkill (since hugetlbfs
pagesize is generally much bigger than your cachesize, you'll
be forced to allocate far more memory than your application
needs).

-Tony
