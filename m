From: Horms <horms@verge.net.au>
Date: Sat, 03 Feb 2007 03:24:58 +0000
Subject: Re: [PATCH] IA64 kexec-tools: memory_ranges arrays scalability issue
Message-Id: <20070203032457.GD3709@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <45C3D89F.1060301@sgi.com>
In-Reply-To: <45C3D89F.1060301@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 02, 2007 at 04:34:39PM -0800, Jay Lan wrote:
> There are two memory_ranges arrays declared in the IA64 kexec code.
> One in kexec-ia64.c and the other one in crashdump-ia64.c.
> 
> They currently were allocated as a hard-coded size of array. Since
> SN systems may scale to hunders of nodes and each node may contain
> up to 12 DIMMs, the hard-coded size of 1024 is not enough for very
> large systems.
> 
> The size of either array can not be greater than the number of
> entries in /proc/iomem, which is saved as "max_memory_ranges"
> and is used to dynamically allocate the two arrays.
> 
> 
> Signed-off-by:  Jay Lan <jlan@sgi.com>
> 

Thanks, applied.


-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

