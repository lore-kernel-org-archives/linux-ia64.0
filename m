From: Andrew Morton <akpm@osdl.org>
Date: Wed, 17 Mar 2004 21:21:00 +0000
Subject: sched-domains
Message-Id: <20040317132100.106f62e7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Folks, I remain all in a dither over the sched-domains NUMA/SMT work which
has been in the -mm kernels for a while.

I have no concerns about its stability, but I do want to see general
agreement that this is the way to proceed, although of course it may need
enhancements/tuning later on.

In terms of performace testing results I believe everything has been
positive except for some testing which Andi did on the STREAM benchmark.

My question is: to what extent have the ia64 NUMA architectural people
reviewed this code, and what is the risk that someone will come along in
six months time saying we need to rip it all out?

Thanks.
