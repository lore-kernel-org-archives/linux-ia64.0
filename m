From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 13 Mar 2004 05:49:10 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040313054910.GA655@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de>
In-Reply-To: <20040313034840.GF4638@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

On Sat, Mar 13, 2004 at 04:48:40AM +0100, Andi Kleen wrote:
> One drawback is that the out of memory handling is lot less nicer
> than it was before - when you run out of hugepages you get SIGBUS
> now instead of a ENOMEM from mmap. Maybe some prereservation would
> make sense, but that would be somewhat harder. Alternatively
> fall back to smaller pages if possible (I was told it isn't easily
> possible on IA64)

That's not entirely true. Whether it's feasible depends on how the
MMU is used. The HPW (Hardware Pagetable Walker) and short mode of the
VHPT insist upon pagesize being a per-region attribute, where regions
are something like 60-bit areas of virtualspace, which is likely what
they're referring to. The VHPT in long mode should be capable of
arbitrary virtual placement (modulo alignment of course).


-- wli
