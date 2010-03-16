From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 16 Mar 2010 01:44:59 +0000
Subject: Re: [PATCH v4 05/11] swiotlb: add swiotlb_set_default_size()
Message-Id: <20100316104440Y.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
	<1268421166-4791-6-git-send-email-albert_herranz@yahoo.es>
In-Reply-To: <1268421166-4791-6-git-send-email-albert_herranz@yahoo.es>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: albert_herranz@yahoo.es
Cc: linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

On Fri, 12 Mar 2010 20:12:40 +0100
Albert Herranz <albert_herranz@yahoo.es> wrote:

> The current SWIOTLB code uses a default of 64MB for the IO TLB area.
> This size can be influenced using a kernel command line parameter "swiotlb".
> Unfortunately, the parsing of the kernel command line is done _after_ the
> swiotlb is initialized on some architectures.
> 
> This patch adds a new function swiotlb_set_default_size() which can be used
> before swiotlb_init() to indicate the desired IO TLB area size in bytes.
> 
> This will be used later to implement a smaller IO TLB on the Nintendo Wii
> video game console which just comes with 24MB + 64MB of RAM.
> 
> CC: linuxppc-dev@lists.ozlabs.org
> CC: linux-kernel@vger.kernel.org
> CC: x86@kernel.org
> CC: linux-ia64@vger.kernel.org
> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
> ---
>  include/linux/swiotlb.h |    2 ++
>  lib/swiotlb.c           |   20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+), 0 deletions(-)

Please fix the powerpc swiotlb initialization instead.

Calling swiotlb_init() before parsing kernel parameters sounds
wrong. Any reasons why you can't fix it?
