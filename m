From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 12 Mar 2004 05:42:04 +0000
Subject: Re: 2.6.3 compilation problem
Message-Id: <20040312054204.GB16214@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

From my very old binutils release note:

---
3. Update handling relocations against the discarded sections. You may
need to apply the kernel patch enclosed here to your kernel source. If
you still see things like

drivers/char/char.o(.data+0x46b4): undefined reference to `local symbols in discarded section .text.exit'

in the final kernel link, that means you have compiled a driver into
the kernel which has a reference to the symbol in a discarded section.
Please check all the builtin drivers and search for things like

static struct pci_driver xxx_pci_driver = {
...
	remove:	       xxx_remove,
...
};

Then check to see if xxx_remove is marked with __devexit like

static void __devexit
xxx_remove (struct pci_dev *dev)
{
...
}

which means it will be discarded if the driver is builtin. If
xxx_remove may be discarded, please make sure there is

#ifdef MODULE
	remove:	       xxx_remove,
#endif

so that xxx_remove won't be included when the driver is builtin.
---

Hope it help.


H.J.
On Fri, Mar 12, 2004 at 11:52:59AM +0800, Liu, Benjamin wrote:
> Sourav,
> 
> Could you please send out your configure file in attachment? I can not reproduce your issue even when I configured CONFIG_SERIO.
> 
> Ken, it's too early to make any judgement.
> 
> Thanks,
> Pingping (Benjamin) Liu
> Intel China Software Center
> 
> 
> >-----Original Message-----
> >From: Chen, Kenneth W 
> >Sent: 2004年3月12日 2:38
> >To: Liu, Benjamin; Sourav Sen; linux-ia64@vger.kernel.org
> >Subject: RE: 2.6.3 compilation problem
> >
> >
> >>>>>> Liu, Benjamin wrote on Thu, March 11, 2004 12:33 AM
> >> To workaround the problem, you can append 
> >__attribute__((weak)) to the
> >> declaration of those discarded symbols defined in section 
> >".exit.text".
> >>
> >> The device driver author might be able to answer why it is 
> >written that
> >> way.
> >
> >The linker gets the award for least informative in this case, 
> >and it just
> >plain misleading.  The culprit isn't the one printed.  It lies 
> >somewhere
> >else.
> >
> >- Ken
> >
> >
> >
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
