From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 16 Aug 2004 15:18:11 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing
Message-Id: <Pine.LNX.4.58.0408160817210.8293@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com>
 <20040815130919.44769735.davem@redhat.com> <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com>
 <20040815165827.0c0c8844.davem@redhat.com> <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com>
 <20040815185644.24ecb247.davem@redhat.com> <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
 <41205BAA.9030800@sgi.com>
In-Reply-To: <41205BAA.9030800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 16 Aug 2004, Ray Bryant wrote:

> Something else to worry about here is mm->rss.  Previously, this was updated
> only with the page_table_lock held, so concurrent increments were not a
> problem.  rss may need to converted be an atomic_t if you use pte_locks.
> It may be that an approximate value for rss is good enough, but I'm not sure
> how to bound the error that could be introduced by a couple of hundred
> processers handling page faults in parallel and updating rss without locking
> it or making it an atomic_t.

Correct. There are a number of issues that may have to be addressed but
first we need to agree on a general idea how to proceed.

