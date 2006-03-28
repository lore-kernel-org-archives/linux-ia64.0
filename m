From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 28 Mar 2006 18:53:52 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <200603281853.k2SIrGg28290@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <4428EF8B.7040202@yahoo.com.au>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Zoltan.Menyhart@free.fr, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Tuesday, March 28, 2006 12:11 AM
> Also, I think there is still the issue of ia64 not having the
> correct memory consistency semantics. To start with, all the bitops
> and atomic ops which both modify their operand and return a value
> should be full memory barriers before and after the operation,
> according to Documentation/atomic_ops.txt.


I suppose the usage of atomic ops is abused, it is used in both lock
and unlock path.  And it naturally suck because it now requires full
memory barrier.  A better way is to define 3 variants: one for lock
path, one for unlock path, and one with full memory fence.

- Ken
