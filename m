From: Greg KH <greg@kroah.com>
Date: Thu, 24 Oct 2002 16:54:11 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 24, 2002 at 10:52:09AM -0400, Jeff Garzik wrote:
> Greg KH wrote:
> >I think we now all agree that resource management should move into a
> >place where it can be shared by all pci hotplug drivers, right?
> >
> >If so, anyone want to propose some common code?
> 
> 
> drivers/pci/setup* is not enough?
> 
> I am surprised that anything needed to be added here...

There was some reason that code would not work out when I looked at it
over a year ago.  But I don't remember why, so I'll go look at it again,
thanks for pointing it out.

greg k-h

