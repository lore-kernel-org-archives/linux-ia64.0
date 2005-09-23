From: Mark Goodwin <markgw@sgi.com>
Date: Fri, 23 Sep 2005 11:10:53 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <Pine.LNX.4.62.0509232050300.8794@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 23 Sep 2005, Paul Jackson wrote:

> This note explains the support provided by cpusets for job placement
> on hyperthreaded CPUs in upcoming products, enabling one to control
> what can run on the A and B sides of each core, if anything.

do we need to accommodate a more generic specification? e.g how about
a system with K sockets per node, L cores per socket and M threads per
core?  And if that's not complicated enough, how about a really large
system where K, L and/or M are not necessarily constant?

-- Mark

