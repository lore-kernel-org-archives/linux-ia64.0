From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Tue, 21 Sep 2004 21:51:50 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <20040921145150.A27211@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <200409201812.45933.dtor_core@ameritech.net> <20040920183845.C17763@unix-os.sc.intel.com> <200409210051.36251.dtor_core@ameritech.net>
In-Reply-To: <200409210051.36251.dtor_core@ameritech.net>; from dtor_core@ameritech.net on Tue, Sep 21, 2004 at 12:51:36AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: acpi-devel@lists.sourceforge.net, Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, "Brown, Len" <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Sep 21, 2004 at 12:51:36AM -0500, Dmitry Torokhov wrote:
> On Monday 20 September 2004 08:38 pm, Keshavamurthy Anil S wrote:
> > Currently I am handling both the surprise removal and the eject request in the same
> > way, i,e send the notification to the userland and the usermode agent scripts
> > is responsible for offlining of all the devices and then echoing onto eject file.
> > 
> 
> I actually think that on the highest level we should treat controlled and
> surprise ejects differently. With controlled ejects the system (kernel +
> userspace) can abort the sequence if something goes wrong while with surprise
> eject the device is physically gone. Even if driver refuses to detach or we
> have partition still mounted or something else if physical device is gone we
> don't have any choice except for trimming the tree and doing whatever we need
> to do.

I agree, but when dealing with devices like CPU and Memory, not sure how the
rest of the Operating System handles surprise removal. For now I will go ahead and
add a PRINTK saying that BUS_CHECK(surprise removal request) was received in the 
ACPI Processor and in the container driver, and when we hit that printk on a 
real hardware, I believe it would be the right time then to see how the OS behaves 
and do the right code then. For Now I will just go ahead and add a PRINTK.

Let me know if this step by step approach is okay to you.

thanks,
Anil

