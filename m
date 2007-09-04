From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Date: Tue, 04 Sep 2007 20:02:42 +0000
Subject: Re: [PATCH] SLUB use cmpxchg_local
Message-Id: <20070904200242.GB8157@Krystal>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827202203.GB5653@Krystal> <Pine.LNX.4.64.0708271324001.5884@schroedinger.engr.sgi.com> <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com> <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com> <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com> <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

* Christoph Lameter (clameter@sgi.com) wrote:
> Measurements on IA64 slub w/per cpu vs slub w/per cpu/cmpxchg_local 
> emulation. Results are not good:
> 

Hi Christoph,

I tried to come up with a patch set implementing the basics of a new
critical section: local_enter(flags) and local_exit(flags).

Can you try those on ia64 and tell me if the results are better ?

See the 2 next posts...

Mathieu
-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
