From: linux-os <linux-os@analogic.com>
Date: Wed, 02 Mar 2005 18:03:47 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <Pine.LNX.4.61.0503021258260.6043@chaos.analogic.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com> <42249A44.4020507@pobox.com>
 <Pine.LNX.4.58.0503010844470.25732@ppc970.osdl.org>
 <20050301165904.GN28741@parcelfarce.linux.theplanet.co.uk>
 <422524B1.10405@jp.fujitsu.com> <20050302174438.GH1220@austin.ibm.com>
In-Reply-To: <20050302174438.GH1220@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Luck, Tony" <tony.luck@intel.com>

On Wed, 2 Mar 2005, Linas Vepstas wrote:

> On Wed, Mar 02, 2005 at 11:28:01AM +0900, Hidetoshi Seto was heard to remark:
>>
>> Note that here is a difficulty: the MCA handler on some arch would run on
>> special context - MCA environment. In other words, since some MCA handler
[SNIPPED...]

>
> /**
> * queue up a pci error event to be dispatched to all listeners
> * of the pci error notifier call chain.  This routine is safe to call
> * within an interrupt context.  The actual event delivery
> * will be from a workque thread.
> */
>
> void eeh_queue_failure(struct pci_dev *dev)
> {
> 	struct eeh_event  *event;
>
>   event = kmalloc(sizeof(*event), GFP_ATOMIC);
>   if (event = NULL) {
>      printk (KERN_ERR "EEH: out of memory, event not handled\n");
>      return 1;
>   }
>
>   event->dev = dev;
>   event->reset_state = rets[0];
>   event->time_unavail = rets[2];
>
>   /* We may be called in an interrupt context */
>   spin_lock_irqsave(&eeh_eventlist_lock, flags);
     ^^^^^^^^^^^^^^^^^^
>   list_add(&event->list, &eeh_eventlist);
>   spin_unlock_irqrestore(&eeh_eventlist_lock, flags);
     ^^^^^^^^^^^^^^^^^^^^^

I don't think this is SMP safe from interrupt-context.
You need the lock when you are building the event-list,
not just when you queue it.

Cheers,
Dick Johnson
Penguin : Linux version 2.6.11 on an i686 machine (5537.79 BogoMips).
  Notice : All mail here is now cached for review by Dictator Bush.
                  98.36% of all statistics are fiction.
