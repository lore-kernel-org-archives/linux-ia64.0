From: Scott Murray <scottm@somanetworks.com>
Date: Thu, 31 Oct 2002 08:03:09 +0000
Subject: [Linux-ia64] Re: [Pcihpd-discuss] PCI hotplug broken on IA64
Message-Id: <marc-linux-ia64-105590709805309@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 30 Oct 2002, Greg KH wrote:

> On Wed, Oct 30, 2002 at 10:55:12PM -0800, Lee, Jung-Ik wrote:
> >
> > Hotplug drivers in drivers/hotplug are for Intel architecture,
> > and the above APIs are available as global for both i386 and ia64.
>
> Right now they are, but I have seen drivers for other architectures, and
> can not change the pci hotplug core to rely on a ia64 and i386 only
> solution, sorry.  Hopefully those other drivers will be in the main tree
> soon.

I'm hopeful we'll see a bunch of drivers for various non-x86 CompactPCI
CPU boards appear if my CompactPCI driver goes in.  If I get the time,
I'll probably take the required bits for the Motorola PowerPC boards from
the code MontaVista released a while back and build something for them
myself.

By the way, Greg, are you interested in patches against 2.5.45, even with
the device unregistration stuff still up in the air?  Barring that and
waiting to see what Russell and Alan are cooking up for PCI resource
reservation, I'm kind of doneish my port to 2.5.

Scott


-- 
Scott Murray
SOMA Networks, Inc.
Toronto, Ontario
e-mail: scottm@somanetworks.com


