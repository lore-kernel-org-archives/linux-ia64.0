From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 19 Jan 2005 03:24:20 +0000
Subject: RE: [Lmbench-users] Re: pipe performance regression on ia64
Message-Id: <894E37DECA393E4D9374E0ACBBE74270013E8A01@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119030506.GA19700@work.bitmover.com>
In-Reply-To: <20050119030506.GA19700@work.bitmover.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Larry McVoy <lm@bitmover.com>, Linus Torvalds <torvalds@osdl.org>
Cc: davidm@hpl.hp.com, carl.staelin@hp.com, "Luck, Tony" <tony.luck@intel.com>, lmbench-users@bitmover.com, linux-ia64@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Larry McVoy
> Sent: Wednesday, January 19, 2005 11:05 AM
> To: Linus Torvalds
> Cc: davidm@hpl.hp.com; carl.staelin@hp.com; Luck, Tony;
> lmbench-users@bitmover.com; linux-ia64@vger.kernel.org; Kernel Mailing
List
> Subject: Re: [Lmbench-users] Re: pipe performance regression on ia64
> 
> I'm very unthrilled with the idea of adding stuff to the release
benchmark
> which is OS specific.  That said, there is nothing to say that you
can't
> grab the benchmark and tweak your own test case in there to prove or
> disprove your theory.
> 

Maybe lmbench could add a feature that bw_pipe will fork CPU number of
children to measure the average throughput. 

This will give a much reasonable result when running bw_pipe on a SMP
Box, at least for Linux.

Zou Nan hai
