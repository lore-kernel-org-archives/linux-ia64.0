From: "Broadfoot, KenX" <kenx.broadfoot@intel.com>
Date: Tue, 29 Aug 2000 16:25:01 +0000
Subject: RE: [Linux-ia64] Is there a kdb patch for Test7 availiable?
Message-Id: <marc-linux-ia64-105590678205404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It still won't work for me....

I have these options set for KDB:
( Under Kernel Hacking )

Kernel support for IA-32 emulation
Kernel FP software completion
Magic SysRq key
Early printk support ( requires VGA! )

Print possible IA64 hazards to console

I do NOT have these picked:

Turn on compare-and-exchange bug checking ( slow! )
Turn on irq debug checks (slow!)
Enable new unwind support

Is the "unwind support" what I need to the KDB stuff to work?

Thanks,

--ken


> -----Original Message-----
> From:	Goutham Rao [SMTP:goutham.rao@intel.com]
> Sent:	Monday, August 28, 2000 8:56 PM
> To:	Broadfoot, KenX
> Cc:	'Bill Nottingham'; linux-ia64@linuxia64.org
> Subject:	Re: [Linux-ia64] Is there a kdb patch for Test7 availiable?
> 
> Hi,
> Using the Pause key will get you into the debugger when the kernel is
> compiled with KDB.  To get a back trace, type "bt" at the prompt.  Type
> "help" to get a full list of commands.
> 
> Thanks
> Goutham
> 
> 
> On Mon, 28 Aug 2000, Broadfoot, KenX wrote:
> 
> > 
> > I have 2.4.0-test7 with the ia64 patch...
> > 
> > I don't know how to make the built in KDB work... is it broken and is
> there
> > a patch?
> > 
> > If it works fine, what is the keystroke for viewing a stack trace?
> > 
> > thanks in advance...
> > 
> > --ken
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > 
> 


