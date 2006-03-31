From: linas@austin.ibm.com (Linas Vepstas)
Date: Fri, 31 Mar 2006 22:01:17 +0000
Subject: Re: [PATCH 1/6] PCIERR : interfaces for synchronous I/O error detection on driver
Message-Id: <20060331220117.GB23872@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44210D1B.7010806@jp.fujitsu.com> <20060322210157.GH12335@kroah.com> <4423A40D.3080906@jp.fujitsu.com> <20060324234306.GC21895@austin.ibm.com> <44274FF0.406@jp.fujitsu.com>
In-Reply-To: <44274FF0.406@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Greg KH <greg@kroah.com>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz

On Mon, Mar 27, 2006 at 11:37:36AM +0900, Hidetoshi Seto wrote:
>  - State check would be architecture dependent routine work.

I read through your patches.  You are proposing a very different
way of handling PCI errors than the pci_error_handlers API.
It seems to be much more invasive, and I don't understand why
its needed or how its better.  Let me be specific:

In the mpt code you have a function called pciras_readl()
that tries to perform an error-free read by retrying the read:

  do {
    pcierr_clear(&cookie, ioc->pcidev);
    val = ioread32(addr);
    status = pcierr_read(&cookie);
  } while(status && (--retries > 0));

Why not create special arch/ia_64 readl routine to do this?
In that case, other device drivers would get the benefit of
the retry-on-error type read.

Now, you probably shouldn't put this into the default readl
routine, since some devices do peculiar things if the same
register is read repeatedly.

Next, I notice that if the repeated read fails, then

   schedule_work(&mptbase_rstTask);

is called. This seems to be exactly the kind of action
that the pci_error_handlers API was meant to provide:
if there is a pci read error that cannot be trivially
recovered, then the error_detected() &c. routines would
be called. The mpt device driver would then initiate
a mptbase_rstTask upon one of these callbacks.

Thus, in the ia64 code, if a repeated readl fails,
then the ia64 reset task calls the device drivers
error_detected() routine, followed by the drivers's 
link_reset() routine, followed by the resume() routine.

For the mpt, it would probably be resume() that was
a wrapper around mptbase_rstTask(). Wouldn't this 
work just as well? 

--linas

