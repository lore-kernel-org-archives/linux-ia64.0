From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 07 Aug 2019 13:35:37 +0000
Subject: Re: RFC: remove sn2, hpsim and ia64 machvecs
Message-Id: <0b5ef759-06c7-4f12-5e8b-ce35d2f25b5c@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Christoph!

On 8/7/19 3:30 PM, Christoph Hellwig wrote:
> let me know what you think of this series.  This drops the pretty much
> dead sn2 and hpsim support, which then allows us to build a single ia64
> kernel image that supports all remaining systems without extra indirections
> in the fast path.

Interesting. Does that mean Debian no longer needs to maintain two different
kernels for ia64, currently named "itanium" and "mckinley"?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
