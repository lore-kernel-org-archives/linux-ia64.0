From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 07 Oct 2004 13:27:10 +0000
Subject: Re: [PATCH] Support ia32 exec domains without CONFIG_IA32_SUPPORT
Message-Id: <20041007142710.A12688@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <41643EC0.1010505@intel.com>
In-Reply-To: <41643EC0.1010505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 06, 2004 at 11:51:44AM -0700, Arun Sharma wrote:
> 
> The attached patch enables the alternate root feature for programs running with a different personality such as PER_LINUX32, even though in-kernel 32 bit support is turned off.
> 
> Although this feature can be emulated at the user level, it's more efficient to do it in the kernel.
> 
> Tony, please apply.

This was rejected for qemu on various arches already.  Please do it in your
userland emulator.

