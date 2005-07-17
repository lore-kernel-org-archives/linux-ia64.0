From: Paul Jackson <pj@sgi.com>
Date: Sun, 17 Jul 2005 04:51:21 +0000
Subject: Re: [NUMA] Display and modify the memory policy of a process
Message-Id: <20050716215121.6c04ffb0.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050715214700.GJ15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
	<20050715220753.GK15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
	<20050715223756.GL15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
	<20050715225635.GM15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
	<20050715234402.GN15783@wotan.suse.de>
	<Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
	<20050716020141.GO15783@wotan.suse.de>
	<20050716163030.0147b6ba.pj@sgi.com>
	<Pine.LNX.4.62.0507162016470.27506@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507162016470.27506@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Christoph wrote:
> Here is one approach to locking using xchg.

What I see here doesn't change the behaviour of the
kernel any - just adds some locked exchanges, right?

I thought the hard part was having some other task
change the current tasks mempolicy.  For example,
how does one task sync another tasks mempolicy up
with its cpuset, or synchronously get the policies
zonelist or preferred node set correctly?

I guess that this approach is intended to show how
to make it easy to add that hard part, right?

... whatever ... guess I'm still missing something ...

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
