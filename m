From: Greg KH <greg@kroah.com>
Date: Wed, 30 Mar 2005 09:45:51 +0000
Subject: Re: [PATCH 3/91] get rid of pci_find_{device,subsys} arch/ia64
Message-Id: <20050330094550.GA12553@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050329122242.GA26755@infradead.org>
In-Reply-To: <20050329122242.GA26755@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 30, 2005 at 12:29:00PM +0530, Amit Gud wrote:
> So if we are to replace pci_find_device with pci_get_device, how should we 
> go about in this particular case, which
> apparently is the case with many other places where pci_find_device is 
> used. The way I did seemed logical to me:
> find the device - accept it - work with it - jerk it off.
> Am I missing out something very obvious?

Please read the last sentence of the documentation for the
pci_get_device() function.  I think you missed that :)

That sentence tells us that you do not need to call pci_dev_put() within
a pci_get_device() while loop.

So please, email all of the maintainers who you sent those patches to
and ask them to not apply them...

thanks,

greg k-h
