From: Greg KH <greg@kroah.com>
Date: Thu, 31 Oct 2002 08:19:21 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 31, 2002 at 03:03:09AM -0500, Scott Murray wrote:
> 
> I'm hopeful we'll see a bunch of drivers for various non-x86 CompactPCI
> CPU boards appear if my CompactPCI driver goes in.  If I get the time,
> I'll probably take the required bits for the Motorola PowerPC boards from
> the code MontaVista released a while back and build something for them
> myself.

Sounds good, further reinforcement of the "no i386 and ia64 only"
restrictions on the pci hotplug core :)

> By the way, Greg, are you interested in patches against 2.5.45, even with
> the device unregistration stuff still up in the air?  Barring that and
> waiting to see what Russell and Alan are cooking up for PCI resource
> reservation, I'm kind of doneish my port to 2.5.

Yes I am, please send them on.

thanks,

greg k-h

