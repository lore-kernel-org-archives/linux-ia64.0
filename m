From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 22 Aug 2006 19:06:23 +0000
Subject: RE: Increase default nodes shift to 10
Message-Id: <617E1C2C70743745A92448908E030B2A6B3C6D@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could we set these limits consitently to the largest IA64 configuration to 
> make sure that a generic IA64 kernel is able to run on all machines?

We could ... but Horms has a good point that we might not
want to do this if the cost is high.  Can you estimate how
much memory will be allocated in these NR_CPUS and MAX_NUMNODES
sized arrays.  If it is only[1] a couple of hundred Kbytes, then
it might be worth it (even little IA-64 systems have 1GB, so
100K is 0.01%).

-Tony

[1] "only" still sounds weird when talking about more memory
than my first UNIX computer (a pdp11/34) had in total to
support up to 30 users.
