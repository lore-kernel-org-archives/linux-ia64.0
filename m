From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 24 Oct 2002 14:52:09 +0000
Subject: [Linux-ia64] Re: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805228@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greg KH wrote:
>>The SHPC specification defines it still depends on ACPI for managing
>>resources, etc.  So resource management portion can be and *should be*
>>shared with all PCI hotplug drivers that use ACPI for resource
>>management.
>>
>>I think the most important thing is everyone agree on the direction
>>in which we should go before we code anything, in order not to waste
>>our time.
> 
> 
> I think we now all agree that resource management should move into a
> place where it can be shared by all pci hotplug drivers, right?
> 
> If so, anyone want to propose some common code?


drivers/pci/setup* is not enough?

I am surprised that anything needed to be added here...


