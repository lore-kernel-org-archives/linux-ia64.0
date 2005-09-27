From: Paul Jackson <pj@sgi.com>
Date: Tue, 27 Sep 2005 16:37:59 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <20050927093759.6bcd0153.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan wrote:
> I think it is a good idea to be able to handle the general case.

One can certainly handle the general case, by explicitly
listing the selected CPUs.

The trade off is in finding a middle path, that is sufficiently
general for most cases, but still easier to use than the brute
force listing the selected CPUs.

I am open to adding a cpuset command option for that middle
path, but I will probably need more inspiration to discover
a good option, and more real life feedback to know what will
be most useful.

> I think we should add the "locality information" into ...

Yes - exposing "locality information" is the half of this
puzzle.  I wish I had been able to spend more time on this
already.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
