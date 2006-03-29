From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 19:55:13 +0000
Subject: RE: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <200603291954.k2TJsSg10937@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Prarit Bhargava wrote on Wednesday, March 29, 2006 10:55 AM
> > Just tried upstream 2.6.16.1 on my Intel tiger4 machine.  It boots OK.
> > What kind of problem do you have?  Where does it hang?
> > 
> 
> I'm trying to get a hold of Emeric to find out what system he's using :)
> 
> But it looks like it is hanging on Altix's at
> 
> Calling initcall 0xa0000001006ad230: bictcp_register+0x0/0x40()
> TCP bic registered
> Calling initcall 0xa0000001006b1160: xfrm_user_init+0x0/0xe0()
> Initializing IPsec netlink socket
> Calling initcall 0xa0000001006ade70: af_unix_init+0x0/0x120()
> NET: Registered protocol family 1
> Calling initcall 0xa0000001006adfc0: packet_init+0x0/0x100()
> NET: Registered protocol family 17
> Calling initcall 0xa0000001006a9670: acpi_poweroff_init+0x0/0x100()
> Calling initcall 0xa0000001006af2d0: seqgen_init+0x0/0x40()
> Calling initcall 0xa0000001006b18d0: early_uart_console_switch+0x0/0x120()
> Calling initcall 0xa0000001006a8e10: net_random_reseed+0x0/0x100()
> Freeing unused kernel memory: 400kB freed

I also tried yesterday's snapshot 2.6.16-git17 on my tiger4, it doesn't
boot :-(

So far we have reports on:

(1) 2.6.16.1 doesn't boot on altix
(2) 2.6.16-git17 doesn't boot on tiger4
(3) Jes's strange .section causing some hangs.

Hmm, I don't know what's going on ....

- Ken
