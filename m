From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Jan 2005 06:35:27 +0000
Subject: RE: [Lmbench-users] Re: pipe performance regression on ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02BFFE3A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119030506.GA19700@work.bitmover.com>
In-Reply-To: <20050119030506.GA19700@work.bitmover.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zou, Nanhai" <nanhai.zou@intel.com>, Larry McVoy <lm@bitmover.com>, Linus Torvalds <torvalds@osdl.org>
Cc: davidm@hpl.hp.com, carl.staelin@hp.com, lmbench-users@bitmover.com, linux-ia64@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

>Maybe lmbench could add a feature that bw_pipe will fork CPU 
>number of children to measure the average throughput. 
>
>This will give a much reasonable result when running bw_pipe 
>on a SMP Box, at least for Linux.

bw_pipe (along with most/all of the lmbench tools already has
a "-P" argument to specify the degree of parallelism).

-Tony
