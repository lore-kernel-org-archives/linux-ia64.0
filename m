From: Russ Anderson <rja@sgi.com>
Date: Tue, 21 Sep 2004 22:23:30 +0000
Subject: Re: [Lhns-devel] Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <200409212223.i8LMNUFV041295@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040921145150.A27211@unix-os.sc.intel.com>
In-Reply-To: <20040921145150.A27211@unix-os.sc.intel.com> from "Keshavamurthy Anil S" at Sep 21, 2004 02:51:50 PM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: anil.s.keshavamurthy@intel.com
Cc: Dmitry Torokhov <dtor_core@ameritech.net>, acpi-devel@lists.sourceforge.net, Brown Len <len.brown@intel.com>, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Keshavamurthy Anil S wrote:
> On Tue, Sep 21, 2004 at 12:51:36AM -0500, Dmitry Torokhov wrote:
> > On Monday 20 September 2004 08:38 pm, Keshavamurthy Anil S wrote:
> > 
> > I actually think that on the highest level we should treat controlled and
> > surprise ejects differently. With controlled ejects the system (kernel +
> > userspace) can abort the sequence if something goes wrong while with surprise
> > eject the device is physically gone. Even if driver refuses to detach or we
> > have partition still mounted or something else if physical device is gone we
> > don't have any choice except for trimming the tree and doing whatever we need
> > to do.
> 
> I agree, but when dealing with devices like CPU and Memory, not sure how the
> rest of the Operating System handles surprise removal.

If by "surprise removal" you mean an Itanium CPU or Memory no longer are 
accessable by the rest of the hardware, the result will be fatal MCA.  For 
example,  if an Itanum CPU tried to load from Memory that no longer exists, 
the load will time out and the CPU will generate a fatal MCA.  It may (or may
not) be possible to enhance the MCA/linux error handling code to handle this 
situation, but the current code does not.

>                                                        For now I will go ahead and
> add a PRINTK saying that BUS_CHECK(surprise removal request) was received in the 
> ACPI Processor and in the container driver, and when we hit that printk on a 
> real hardware, I believe it would be the right time then to see how the OS behaves 
> and do the right code then. For Now I will just go ahead and add a PRINTK.
> 
> Let me know if this step by step approach is okay to you.
> 
> thanks,
> Anil


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
