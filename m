From: Greg KH <greg@kroah.com>
Date: Thu, 06 May 2004 16:40:40 +0000
Subject: Re: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <20040506164040.GA15371@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: Matt_Domsch@dell.com, matthew.e.tolentino@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 06, 2004 at 02:22:46PM +0530, Sourav Sen wrote:
> 
> The following simple patch creates a read-only file
> "memmap" under <mount point>/firmware/efi/ in sysfs
> and exposes the efi memory map thru it.

No, data in this kind of format does not belong in sysfs.

thanks,

greg k-h
