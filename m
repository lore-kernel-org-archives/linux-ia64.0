From: Alex Williamson <awilliam@fc.hp.com>
Date: Wed, 25 Jul 2001 14:32:28 +0000
Subject: Re: [Linux-ia64] Big problems with 2.4.7
Message-Id: <marc-linux-ia64-105590693005910@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005908@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005908@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Martin,

   I'm suspicious that perhaps your I/O Port space base address is not
getting set.  We're trying to get it from the EFI memory map in this
kernel rather than from what firmware leaves in AR.K0.  This is the
way that Intel recommends doing it, so I'm rather surprised it's not
working.  Are you running the latest firmware on the Lion?  You could
either try to revert the change in arch/ia64/kernel/setup.c line ~308
that gets it from EFI and sets AR.K0 to just get the value from AR.K0.
Or, you could put a printk in there to see if EFI returning a something
valid (should be top of addressable space minus 64MB).  Thanks,

	Alex


Martin Wilck wrote:
> 
> The suspicious messages at boot are:
> - "keyboard timeout - AT keyboard not present ?" (drivers/char/pc_keyb.c)
> - "hda: IRQ probe failed (0xfffffffffffffdfe)" (drivers/ide/ide-probe.c)
> The latter message repeats twice for IDE devices hda ... hdd.
> 


--
Alex Williamson                                  Linux Development Lab
awilliam@fc.hp.com                                     Hewlett Packard
970-898-9173                                          Fort Collins, CO

