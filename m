From: Dmitry Torokhov <dtor_core@ameritech.net>
Date: Tue, 21 Sep 2004 05:51:36 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <200409210051.36251.dtor_core@ameritech.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <200409201812.45933.dtor_core@ameritech.net> <20040920183845.C17763@unix-os.sc.intel.com>
In-Reply-To: <20040920183845.C17763@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Cc: "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Monday 20 September 2004 08:38 pm, Keshavamurthy Anil S wrote:
> Currently I am handling both the surprise removal and the eject request in the same
> way, i,e send the notification to the userland and the usermode agent scripts
> is responsible for offlining of all the devices and then echoing onto eject file.
> 

I actually think that on the highest level we should treat controlled and
surprise ejects differently. With controlled ejects the system (kernel +
userspace) can abort the sequence if something goes wrong while with surprise
eject the device is physically gone. Even if driver refuses to detach or we
have partition still mounted or something else if physical device is gone we
don't have any choice except for trimming the tree and doing whatever we need
to do.

> My worry is if we implement a generic handler for BUS_CHECK, then what would you 
> do if the device fails to remove, i.e what action to take if the device remove fails?
> 

It could depend on parent's status. If parent is gone (surprise removal) we will
trim. If it is controlled removal and driver does not let device go we could
abort eject. 

Or we could always trim and offload the responsibility of having the system in
ready-to-eject state to the userspace. I.e. it should not write into "eject"
unless everything is unmounted/shut down/disconnected.

I am a bit light on implementation details though ;)

-- 
Dmitry
