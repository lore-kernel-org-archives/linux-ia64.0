From: "BURRELL,JEFF (HP-FtCollins,ex1)" <jeff.burrell@hp.com>
Date: Fri, 01 Aug 2003 21:21:27 +0000
Subject: RE: video cards for zx1 systems?
Message-Id: <marc-linux-ia64-105977290509478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105976717703565@msgid-missing>
In-Reply-To: <marc-linux-ia64-105976717703565@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A couple of additions to Alex' comments.  There's now a working driver for
the ATI FireGL X1 and Z1 cards and those cards will begin shipping early to
mid September as an officially supported product configuration from HP. This
driver works with the shipping Red Hat AW 2.1 bits(i.e. Xfree 4.1).  The
Nvidia Quadro products(eg. 900/750/550/380) should work, though we haven't
tested them all.  Nvidia claims(unofficially) that the newer consumer
cards(GeForce4) should work, but I've heard of some spotty results. 

Avoid any card that requires a separate power connection if you're putting
it in a zx6000.  There is no officially supported way to power those
cards(eg. FX2000, FX3000) from the AGP/PCI card cage on a zx6000, although
they work just fine in a zx2000.  I'm not familiar enough with the form of
the consumer FX cards to know if there are versions that need external
power, but I wouldn't be surprised, given how much power they require.

Jeff Burrell
HP Workstations
Linux R&D

-----Original Message-----
From: Alex Williamson [mailto:alex_williamson@hp.com] 
Sent: Friday, August 01, 2003 1:33 PM
To: Duraid Madina
Cc: linux-ia64@vger.kernel.org
Subject: Re: video cards for zx1 systems?



   The officially supported list is pretty small; Radeon 7000, Nvidia Quadro
2EX, Nvidia Quadro 4 980 XGL, ATI FireGL (need X 4.3).  I've only been able
to try a couple outside of this list.  I haven't had much luck with Matrox.
Unoffically, the older Quadro 2 card that shipped in BigSur systems works.
I would guess that most ATI Radeon based cards work.  Haven't had a GeForce
to try, but I would have assumed that it would work.  I've used a Rage 128
under X, but I don't remember if I was using it for my console.

   The cards are normal PC video cards, but that's also the reason that the
supported list isn't longer.  The BIOS on the card contains an x86 option
ROM.  Execution of the option ROM is emulated in firmware since the zx1
boxes are legacy free.  The beep code you're getting means that firmware
hung.  Do you get anything out of the serial console when this happens?
Might want to make sure you system is up to the latest firmware as well.

	Alex


Duraid Madina wrote:
> 
> Hi all,
> 
>         If I head down to the local computer shop and buy a common AGP 
> video card (I'm thinking Nvidia FX5600 or Matrox P650-type hardware 
> here), can I expect this to work in a zx6000? Do video cards for 
> Itanium systems need a special BIOS, in order for them to work during 
> boot (i.e. will I be able to see EFI or do I have to boot "blind"?), 
> or do normal PC video cards work unchanged?
> 
>         Any data points would be welcome - here's one to add to the 
> list: My old AGP GeForce 3 card leads to the six beeps of death on my 
> zx6000.
> 
>         Thanks in advance,
> 
>         Duraid

-- 
Alex Williamson                             HP Linux & Open Source Lab
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
