From: Greg KH <greg@kroah.com>
Date: Mon, 23 Feb 2004 20:23:13 +0000
Subject: Re: [2.6 PATCH] Altix hotplug
Message-Id: <20040223202313.GA22207@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402231455.i1NEtEqJ041950@fsgi900.americas.sgi.com>
In-Reply-To: <200402231455.i1NEtEqJ041950@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pat Gefre <pfg@sgi.com>
Cc: davidm@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Feb 23, 2004 at 08:55:14AM -0600, Pat Gefre wrote:
> 
> 2.6 Altix patch for kernel hotplug support

You mean "PCI hotplug support" right?

If so, how?  I do not see a single call to pci_hp_register() or friends
here.  What is the userspace interface to your pci hotplug system?

thanks,

greg k-h
