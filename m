From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 17 Sep 2012 11:34:23 +0000
Subject: Re: [PATCH v2 1/2] PCI: Keep pci_fixup_irqs() around after init
Message-Id: <20120917113423.GA28759@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1347880974-13615-1-git-send-email-thierry.reding@avionic-design.de>
In-Reply-To: <1347880974-13615-1-git-send-email-thierry.reding@avionic-design.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Sep 17, 2012 at 01:22:53PM +0200, Thierry Reding wrote:
> Remove the __init annotations in order to keep pci_fixup_irqs() around
> after init (e.g. for hotplug). This requires the same change for the
> implementation of pcibios_update_irq() on all architectures. While at
> it, all __devinit annotations are removed as well, since they will be
> useless now that HOTPLUG is always on.
> 
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
> ---
> Changes in v2:
> - remove __init and __devinit annotations altogether

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
