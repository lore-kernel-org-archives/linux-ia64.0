From: Horms <horms@verge.net.au>
Date: Wed, 13 Dec 2006 02:05:59 +0000
Subject: Re: [patch 0/5] Physical mode SAL calls
Message-Id: <20061213020558.GD22902@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
In-Reply-To: <20061023084840.730815639@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 23, 2006 at 10:15:58AM -0500, Jack Steiner wrote:
> SN systems support additional vendor-specific SAL calls. Some
> of these pass kernel addresses to SAL for input or output buffers.
> At a minimum, these buffer addresses need to be converted to 
> physical addresses if SAL is run in physical mode.

That is sounds quite problematic in terms of not mapping EFI.

Appart from fixing up broken code paths, the main motivation for this
patch is to allow kexecing between different operating systems (e.g.
from xen to linux and vice versa) which have different base addresses.
In a nutshell, get arround the fact that you can't remap EFI on the
second boot by never mapping it at all.

Do you think it is at all possible for this kind of approach to work on
SN systems? If not, the next best idea that I have is to somehow
virtualise the EFI, and have all kexeable systems (linux, xen, ...)
agree to use that. But that idea is farily complex, and I'm not
even sure it can work.

> In addition, I think there may be additional problems with our SAL
> if we try to run only in physical mode. I'll take a look.....

Thanks

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

