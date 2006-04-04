From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 04 Apr 2006 14:40:42 +0000
Subject: Re: Fix ia64 bit ops: Full barriers for bit operations returning a
Message-Id: <Pine.LNX.4.64.0604040739300.26652@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Apr 2006, Zoltan Menyhart wrote:

> Could you consider using some cache hints, like "ld8.bias.nta"?
> "bias" is a hint to acquire exclusive ownership.
> "nta" is a hint to allocate the cache line only in L2
> (and side effect: to bias it to be replaced).
> All of the Itanium 2 processor's atomic instructions are handled
> exclusively by the L2 cache.

Could you come up with a patch? Currently, I do not seem to be able to 
spend enough time on it.
