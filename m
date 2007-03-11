From: Andi Kleen <ak@suse.de>
Date: Sun, 11 Mar 2007 07:54:05 +0000
Subject: Re: [QUICKLIST 4/6] x86_64: Single Quicklist
Message-Id: <200703110854.05799.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com> <20070311020944.19905.87599.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020944.19905.87599.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, ak@suse.com, linux-ia64@vger.kernel.org, holt@sgi.com, mpm@selenic.com

On Sunday 11 March 2007 03:09, Christoph Lameter wrote:
> x86_64: Convert to use a single quicklists
> 
> This adds caching of pgds and puds, pmds, pte. That way we can
> avoid costly zeroing and initialization of special mappings in the
> pgd.
> 
> The first patch just adds a simple implementation using a single
> quicklist. As a consequence we need to zero a pgd before returning
> it to the pool.


This and i386 version are ok to me, although it might be better to just
finish __GFP_ZERO support to do this.

-Andi
