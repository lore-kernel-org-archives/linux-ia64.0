From: "John Hawkes" <hawkes@sgi.com>
Date: Thu, 18 Mar 2004 23:35:51 +0000
Subject: Re: sched-domains
Message-Id: <00db01c40d41$cf16f4c0$e3069aa3@PCJohn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040317132100.106f62e7.akpm@osdl.org>
In-Reply-To: <20040317132100.106f62e7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Andrew Morton" <akpm@osdl.org>
...
> My question is: to what extent have the ia64 NUMA architectural people
> reviewed this code, and what is the risk that someone will come along in
> six months time saying we need to rip it all out?

I am generally happy with the architecture of sched-domains.  The big
advantage I see for large Altix-like NUMA platforms is that much of the
scheduler policy decisions are parameterized in sched_domain fields and are
more easily tuned on a per-architecture and per-platform basis.  In
particular, it is easy to define additional scheduler domains that are larger
than a single node and smaller than all the CPUs in the system, each domain
having its own parameterized characteristics of load-balance frequency, etc.

John Hawkes


