From: William Lee Irwin III <wli@holomorphy.com>
Date: Sun, 14 Mar 2004 00:05:06 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040314000506.GE655@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de> <20040313054910.GA655@holomorphy.com> <20040313161010.GB15118@wotan.suse.de>
In-Reply-To: <20040313161010.GB15118@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

At some point in the past, I wrote:
>> That's not entirely true. Whether it's feasible depends on how the
>> MMU is used. The HPW (Hardware Pagetable Walker) and short mode of the
>> VHPT insist upon pagesize being a per-region attribute, where regions
>> are something like 60-bit areas of virtualspace, which is likely what
>> they're referring to. The VHPT in long mode should be capable of
>> arbitrary virtual placement (modulo alignment of course).

On Sat, Mar 13, 2004 at 05:10:10PM +0100, Andi Kleen wrote:
> Redesigning the low level TLB fault handling for this would not count as
> "easily" in my book.

I make no estimate of ease of implementation of long mode VHPT support.
The point of the above is that the virtual placement constraint is an
artifact of the implementation and not inherent in hardware.


-- wli
