From: Matt Mackall <mpm@selenic.com>
Date: Sat, 28 Aug 2004 15:48:42 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64 support added
Message-Id: <20040828154842.GM5414@waste.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com> <20040827172337.638275c3.davem@davemloft.net> <20040827173641.5cfb79f6.akpm@osdl.org> <20040828010253.GA50329@muc.de> <20040827183940.33b38bc2.akpm@osdl.org> <16687.59671.869708.795999@cargo.ozlabs.ibm.com> <Pine.LNX.4.58.0408272021070.16607@schroedinger.engr.sgi.com> <20040827204241.25da512b.akpm@osdl.org> <Pine.LNX.4.58.0408272121300.16949@schroedinger.engr.sgi.com> <20040827223954.7d021aac.akpm@osdl.org>
In-Reply-To: <20040827223954.7d021aac.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, paulus@samba.org, ak@muc.de, davem@davemloft.net, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

On Fri, Aug 27, 2004 at 10:39:54PM -0700, Andrew Morton wrote:

> As I said - for both these applications we need a new type which is
> atomic64_t on 64-bit and atomic_t on 32-bit.

atomic_long_t -> longest available atomic type?

-- 
Mathematics is the supreme nostalgia of our time.
