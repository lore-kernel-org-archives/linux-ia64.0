From: Greg KH <greg@kroah.com>
Date: Fri, 13 May 2005 16:39:12 +0000
Subject: Re: [PATCH 3/6]: hotplug/ia64: SN Hotplug Driver - pci_find_next_bus export
Message-Id: <20050513163912.GG11089@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835E79.5040209@sgi.com>
In-Reply-To: <42835E79.5040209@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 08:45:53PM -0400, Prarit Bhargava wrote:
> +EXPORT_SYMBOL(pci_find_next_bus);

EXPORT_SYMBOL_GPL() please.

greg k-h
