From: William Lee Irwin III <wli@holomorphy.com>
Date: Sat, 28 Aug 2004 06:03:51 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support added
Message-Id: <20040828060351.GH2793@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040827172337.638275c3.davem@davemloft.net> <20040827173641.5cfb79f6.akpm@osdl.org> <20040828010253.GA50329@muc.de> <20040827183940.33b38bc2.akpm@osdl.org> <16687.59671.869708.795999@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com> <20040827204241.25da512b.akpm@osdl.org> <Pine.LNX.4.58.0408272121300.16949@schroedinger.engr.sgi.com> <20040827223954.7d021aac.akpm@osdl.org> <Pine.LNX.4.58.0408272256030.17485@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408272256030.17485@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, paulus@samba.org, ak@muc.de, davem@davemloft.net, ak@suse.de, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Fri, 27 Aug 2004, Andrew Morton wrote:
>> atomic64_t already appears to be implemented on alpha, ia64, mips, s390 and
>> sparc64.
>> As I said - for both these applications we need a new type which is
>> atomic64_t on 64-bit and atomic_t on 32-bit.

On Fri, Aug 27, 2004 at 10:58:09PM -0700, Christoph Lameter wrote:
> That is simply a new definition in include/asm-*/atomic.h
> so
> #define atomic_long atomic64_t
> on 64 bit
> and
> #define atomic_long atomic_t
> on 32bit?

The operations must also be defined on them, and the remaining 64-bit
architectures must implement them also.


-- wli
