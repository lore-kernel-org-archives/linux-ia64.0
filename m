From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Mon, 27 Mar 2006 02:37:36 +0000
Subject: Re: [PATCH 1/6] PCIERR : interfaces for synchronous I/O error detection
Message-Id: <44274FF0.406@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44210D1B.7010806@jp.fujitsu.com> <20060322210157.GH12335@kroah.com> <4423A40D.3080906@jp.fujitsu.com> <20060324234306.GC21895@austin.ibm.com>
In-Reply-To: <20060324234306.GC21895@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Greg KH <greg@kroah.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz

Linas Vepstas wrote:
> On Fri, Mar 24, 2006 at 04:47:25PM +0900, Hidetoshi Seto wrote:
>> However, some difficulty still remains to cover all possible error
>> situations even if we use callbacks. It will not help keeping data
>> integrity, passing no broken data to drivers and user lands, preventing
>> applications from going crazy or sudden death.
> 
> This is not true.  Although there are some subtle issues, (which
> I invite you to describe), the goal of the current design is to 
> insure data integrity, and make sure that neither the driver nor 
> the userland gets corrupted data. There shouldn't be any "crazy
> or sudden death" if the device drivers are any good.

OK, we are sharing the same goal even now.

I failed to mention that as you know this synchronous error detection
would be required if the async-callback needs to touch the hardware
due to recover it or to pick up diagnostic data during kernel-initiated
recovery. (I found a word "pci_check_whatever() API" at your comment
in document, Documentation/pci-error-recovery.txt)

> Of course, this depends on the hardware implementation. If
> your PCI bus sends corrupt data up to the driver ... all bets 
> are off. The design is predicated on the assumption that the
> hardware sends either good data or no data, ad that the latter
> is associated with a bus state indicating an error has ocurred.
> 
>>  - It will be useful if arch chooses panic on bus errors not to pass
>>    any broken data to un-reliable drivers.
> 
> I assume you meant "if arch chooses NOT to panic on bus errors ..."

Hmm, what I meant is that:
   There is an arch that chooses reboot on bus error.
   The reason why it do so is that the design is based on the assumption
   that no driver is able to handle bus error and that almost all drivers
   will go without checking hardware status. So the arch chooses rebooting
   rather than polluting user data.
   The design allows OS to determine whether the system goes reboot or not,
   but OS has no idea to know which driver actually check hardware state.
Therefore this interface will help OS to know which driver is reliable.

Of course there are some arch that chooses not to panic/reboot on bus error.
I think they are believing that all drivers working on the arch can handle
any type of errors, or they have their special feature against errors...,
or just being idiot about hardware errors.

Anyway, all that is certain is that:
  - To check the data from hardware, driver need to ask anywhere synchronously.
  - "Anywhere" would be a register, and/or something in kernel/hardware.
  - State check would be architecture dependent routine work.

Thanks,
H.Seto

