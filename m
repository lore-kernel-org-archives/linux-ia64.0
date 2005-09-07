From: Grant Grundler <iod00d@hp.com>
Date: Wed, 07 Sep 2005 16:14:23 +0000
Subject: Re: Prefetch kernel stacks to speed up context switch
Message-Id: <20050907161423.GA30660@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509070829.j878TSg25898@unix-os.sc.intel.com> <2cd57c900509070152518fac06@mail.gmail.com>
In-Reply-To: <2cd57c900509070152518fac06@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Coywolf Qi Hunt <coywolf@gmail.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>

On Wed, Sep 07, 2005 at 04:52:17PM +0800, Coywolf Qi Hunt wrote:
> On 9/7/05, Chen, Kenneth W <kenneth.w.chen@intel.com> wrote:
> > Repost previously discussed patch (on Jul 27, 2005).

For reference:
http://www.gelato.unsw.edu.au/archives/linux-ia64/0507/14686.html

> Do you have any benchmarks?

Have you read the discussion?
See:
    http://www.gelato.unsw.edu.au/archives/linux-ia64/0507/14685.html

Ken didn't post any benchmark results originally but clearly
stated the cacheline misses were occurring enough to be measurable.
Just knowing which workload and how much much time was spent
stalling for cacheline misses should be sufficient.

grant
