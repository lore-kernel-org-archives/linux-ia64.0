From: Tim Riker <TimR@CalderaSystems.com>
Date: Thu, 18 May 2000 21:34:52 +0000
Subject: Re: [Linux-ia64] How do I set variables in efishell?
Message-Id: <marc-linux-ia64-105590678205097@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205073@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205073@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes? I've saved variables from one reboot to another. I was using a
workstation (bigsur) with 0.29 PAL, but it worked for me.

note also there is a dmpstore command which shows all the variables.

Johannes Erdfelt wrote:
> 
> Plus the fact I haven't found a single version of the firmware which
> actually saves these variables. So setting them tends to be useless.
> 
> It hasn't been too important so I haven't followed up on it with Intel.
> 
> JE
> 
> On Thu, May 18, 2000, Tim Riker <TimR@CalderaSystems.com> wrote:
> > >From what I can glean from the docs and my hacking, a set in the shell
> > sets a shell variable, NOT a root EFI variable. The only way to set the
> > EFI variables is to do so from a C app usinf the EFI toolkit. This is a
> > bit unfortunate as it means one can not add/edit menu items from the
> > shell prompt. Also, typing exit at the prompt puts you into the boot
> > menu, but AFAIK there is no way of getting back to the shell.
> >
> >  Chris Hyser wrote:
> > >
> > > Hi All,
> > >
> > > > -----Original Message-----
> > > > From: linux-ia64-admin@linuxia64.org
> > > > [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Christoph Rohland
> > > > Sent: Tuesday, May 09, 2000 3:02 AM
> > > > To: linux-ia64@linuxia64.org
> > > > Subject: [Linux-ia64] How do I set variables in efishell?
> > > >
> > > >
> > > > Hi all,
> > > >
> > > > I still do not know how to set variables in efishell to switch the
> > > > console to my serial device.
> > > >
> > > > I actually know that I have to set the variables ConIn and ConOut. But
> > > > I am prettty confused by any documentation I can find about actually
> > > > setting these variables.
> > > >
> > > > Any help appreciated
> > >
> > > Has anybody figured this out yet? Specifically, there is a "set" command in
> > > the EFI shell, but the difficulty seems to be figuring out the device path
> > > to actually set the variables to. Then of course this early firmware may end
> > > up ignoring them anyway. Thoughts?
> > >
> > > ---
> > > Best Regards
> > > Chris Hyser
> > > Hewlett-Packard
> > >
> > > _______________________________________________
> > > Linux-IA64 mailing list
> > > Linux-IA64@linuxia64.org
> > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> >
> > --
> > Tim Riker - http://rikers.org/ - short SIGs! <g>
> > All I need to know I could have learned in Kindergarten
> > ... if I'd just been paying attention.
> >
> >
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> >
--
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.


