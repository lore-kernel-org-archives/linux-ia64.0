From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 31 Jan 2006 19:24:01 +0000
Subject: RE: [patch 5/6] remove per-cpu ia64_phys_stacked_size_p8
Message-Id: <200601311924.k0VJO9g01579@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
In-Reply-To: <200601310928.k0V9Seg14417@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger-Tang wrote on Tuesday, January 31, 2006 9:40 AM
> To be safe, I think you need to default to the maximum number of
> physical stacked registers (which is somewhere around 16,384, based on
> the width of the ARC.RSC.LOADRS field).

Do I really need to do that?  I'm checking physical stack register
size at time of cpu_init() and patch the kernel code to use largest
size found in the entire system.  Wouldn't that be enough?


> Also, did you verify that the
> patching is indeed atomic (we just modify a few bits, so we're
> *probably* OK, but it needs to be verified that the bits we modify
> don't straddle a word-boundary)?

Yes I did.  The patch instruction is in the first slot of a bundle,
which doesn't straddle word boundary.

- Ken

