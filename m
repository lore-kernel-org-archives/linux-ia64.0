From: Andrew Morton <akpm@osdl.org>
Date: Tue, 08 Feb 2005 01:09:47 +0000
Subject: Re: prezeroing V6 [2/3]: ScrubD
Message-Id: <20050207170947.239f8696.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
	<1106828124.19262.45.camel@hades.cambridge.redhat.com>
	<20050202153256.GA19615@logos.cnet>
	<Pine.LNX.4.58.0502071127470.27951@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0502071131260.27951@schroedinger.engr.sgi.com>
	<20050207163035.7596e4dd.akpm@osdl.org>
	<Pine.LNX.4.58.0502071646170.29971@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0502071646170.29971@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter <clameter@sgi.com> wrote:
>
> > What were the benchmarking results for this work?  I think you had some,
> > but this is pretty vital info, so it should be retained in the changelogs.
> 
> Look at the early posts. I plan to put that up on the web. I have some
> stats attached to the end of this message from an earlier post.

But that's a patch-specific microbenchmark, isn't it?  Has this work been
benchmarked against real-world stuff?

> > Should we be managing the kernel threads with the kthread() API?
> 
> What would you like to manage?

Startup, perhaps binding the threads to their cpus too.
