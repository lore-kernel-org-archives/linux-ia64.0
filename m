From: Simon Derr <Simon.Derr@bull.net>
Date: Fri, 26 Sep 2003 07:36:47 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106456185901844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 25 Sep 2003, Shailabh Nagar wrote:

> Coming to memory, it wasn't very clear what CPUSETs future
> plans/objectives are. Does it intend to control which address ranges a
> CPUSET can allocate from (for NUMA reasons) AND limit how much memory it
> can consume ? The latter intersects with CKRM objectives, the former
> doesn't.
The future plans are still to be decided. The control on memory provided
by future versions of CPUSET might be to:
-associate one node on wich to allocate memory to each cpuset
-associate one allocation policy (local node first, round robin) to each
cpuset.

At first glance, limiting the amount of memory used will probably not be
in our objectives. The initial goal of CPUSET was obtaining good
performance on NUMA architectures. But this is an open question.

> Finally, CKRM is dealing with I/O and planning to incorporate inbound
> and possibly outbound networking into its framework which would appear
> to be outside the scope of something like CPUSETs.
That's right.


	Simon.

