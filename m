From: Andi Kleen <ak@suse.de>
Date: Sat, 13 Mar 2004 16:10:10 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040313161010.GB15118@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de> <20040313054910.GA655@holomorphy.com>
In-Reply-To: <20040313054910.GA655@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: William Lee Irwin III <wli@holomorphy.com>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

> > fall back to smaller pages if possible (I was told it isn't easily
> > possible on IA64)
> 
> That's not entirely true. Whether it's feasible depends on how the
> MMU is used. The HPW (Hardware Pagetable Walker) and short mode of the
> VHPT insist upon pagesize being a per-region attribute, where regions
> are something like 60-bit areas of virtualspace, which is likely what
> they're referring to. The VHPT in long mode should be capable of
> arbitrary virtual placement (modulo alignment of course).

Redesigning the low level TLB fault handling for this would not count as
"easily" in my book.

-Andi
