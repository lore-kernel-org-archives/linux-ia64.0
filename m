From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 14 Dec 2005 00:06:21 +0000
Subject: Re: [patch 1/2] /dev/mem __HAVE_PHYS_MEM_ACCESS_PROT tidy-up
Message-Id: <20051213.160621.98128378.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200512131656.11601.bjorn.helgaas@hp.com>
In-Reply-To: <200512131656.11601.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bjorn.helgaas@hp.com
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org

From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 13 Dec 2005 16:56:11 -0700

> Tidy up __HAVE_PHYS_MEM_ACCESS_PROT usage to make mmap_mem() easier to read.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

It would be _really_ easy to read if the default implementation
lived in some asm-generic/foo.h header file :-)
