From: Alex Williamson <alex_williamson@hp.com>
Date: Fri, 01 Aug 2003 20:32:49 +0000
Subject: Re: video cards for zx1 systems?
Message-Id: <marc-linux-ia64-105977030106863@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105976717703565@msgid-missing>
In-Reply-To: <marc-linux-ia64-105976717703565@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   The officially supported list is pretty small; Radeon 7000, Nvidia
Quadro 2EX, Nvidia Quadro 4 980 XGL, ATI FireGL (need X 4.3).  I've
only been able to try a couple outside of this list.  I haven't had
much luck with Matrox.  Unoffically, the older Quadro 2 card that
shipped in BigSur systems works.  I would guess that most ATI Radeon
based cards work.  Haven't had a GeForce to try, but I would have
assumed that it would work.  I've used a Rage 128 under X, but I don't
remember if I was using it for my console.

   The cards are normal PC video cards, but that's also the reason
that the supported list isn't longer.  The BIOS on the card contains
an x86 option ROM.  Execution of the option ROM is emulated in firmware
since the zx1 boxes are legacy free.  The beep code you're getting
means that firmware hung.  Do you get anything out of the serial
console when this happens?  Might want to make sure you system is up
to the latest firmware as well.

	Alex


Duraid Madina wrote:
> 
> Hi all,
> 
>         If I head down to the local computer shop and buy a common AGP video
> card (I'm thinking Nvidia FX5600 or Matrox P650-type hardware here), can I
> expect this to work in a zx6000? Do video cards for Itanium systems need a
> special BIOS, in order for them to work during boot (i.e. will I be able to
> see EFI or do I have to boot "blind"?), or do normal PC video cards work
> unchanged?
> 
>         Any data points would be welcome - here's one to add to the list: My
> old AGP GeForce 3 card leads to the six beeps of death on my zx6000.
> 
>         Thanks in advance,
> 
>         Duraid

-- 
Alex Williamson                             HP Linux & Open Source Lab
