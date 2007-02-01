From: Horms <horms@verge.net.au>
Date: Thu, 01 Feb 2007 02:46:25 +0000
Subject: Re: [Fastboot] [PATCH] IA64 kexec-tools: efi_memmap overflow on large systems
Message-Id: <20070201024623.GA20278@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 31, 2007 at 05:54:22PM -0800, Jay Lan wrote:
> This patch fixes a efi_memmap overflow problem on large system.
> Currently the kexec allocates statically 16k buffer to contain
> efi_memmap. It can hold about 333 entries. It causes data
> corruption on large system.
> 
> This patch would let kexec allocate the efi_memmap at run time using
> the actual size allocated in the production kernel.
> 
> 
> Signed-off-by: Jay Lan <jlan@sgi.com>

Thanks, applied.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

