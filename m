From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 26 Jan 2006 15:14:19 +0000
Subject: Re: [patch] fix ia64_hint definition for intel compiler intrinsic
Message-Id: <20060126151419.GA2115@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
In-Reply-To: <200601260424.k0Q4OXg05063@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 25, 2006 at 08:24:33PM -0800, Chen, Kenneth W wrote:
> Map ia64_hint() to internal intel compiler intrinsic.
> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> ---
> Compile tested on selective files.  icc 9.0 appears to have
> memory clobber behavior for the hint@pause intrinsic similar
> to gcc with "memory" clobber modifier. Your mileage may vary.
> 
> 
> --- ./include/asm-ia64/intel_intrin.h.orig	2006-01-25 17:40:12.468497883 -0800
> +++ ./include/asm-ia64/intel_intrin.h	2006-01-25 21:04:41.921472582 -0800

include/asm-ia64/intel_intrin.h should just include <ia64intrin.h>.
Why not check out my patch:

http://marc.theaimsgroup.com/?l=linux-ia64&m3475932502202&w=2


H.J.
