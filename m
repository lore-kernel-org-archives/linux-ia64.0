From: Greg KH <greg@kroah.com>
Date: Thu, 31 Oct 2002 07:40:21 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 30, 2002 at 10:55:12PM -0800, Lee, Jung-Ik wrote:
> 
> Hotplug drivers in drivers/hotplug are for Intel architecture,
> and the above APIs are available as global for both i386 and ia64.

Right now they are, but I have seen drivers for other architectures, and
can not change the pci hotplug core to rely on a ia64 and i386 only
solution, sorry.  Hopefully those other drivers will be in the main tree
soon.

> Actually, acpi driver uses them for ACPI/PCI population before 
> pci_dev is built for the hierarchy.

Yes, but acpi is only on ia64 and i386 platforms right now.  And for 2.5
I got rid of that usage :)

thanks,

greg k-h

