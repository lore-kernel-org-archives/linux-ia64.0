From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 06 May 2004 10:44:14 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040506114414.A14543@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>; from souravs@india.hp.com on Thu, May 06, 2004 at 02:22:46PM +0530
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
> Hi,
> 
> The following simple patch creates a read-only file
> "memmap" under <mount point>/firmware/efi/ in sysfs
> and exposes the efi memory map thru it.

doesn't exactly fit into the one value per file approach, does it?

