From: Stephan Schreiber <info@fs-driver.org>
Date: Tue, 02 Oct 2012 19:48:59 +0000
Subject: Re: [RFC/PATCH v2] ia64, SR870, EFI bug breaks ata_piix, uninitialized ICH4 IDE EXBAR mem resource
Message-Id: <20121002214859.Horde.WGw4bbuWis5Qa0Ur8aFhtEA@webmail.df.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120916183914.Horde._TGALdjz9kRQVgCy6ATxxJA@webmail.df.eu>
 <20120917115619.13d3a3cb@pyramind.ukuu.org.uk>
 <20120920161603.Horde.aF7BBcL8999QWyUjk2AmsNA@webmail.df.eu>
 <CAErSpo6+WYE6wnj4CcKVidNHmg-oGH9SBsvg3QP9syC+vo09HQ@mail.gmail.com>
 <20120924190912.Horde.qznUIqGZi1VQYJO46HeGkwA@webmail.df.eu>
 <20120924235457.GA31372@google.com>
 <20120930000934.Horde.grdOKKGZi1VQZ3GeI_YW9ZA@webmail.df.eu>
 <CAErSpo4ErJsp5pWNLsu3x4YL9ZrtxHfk0tkYL7hZaY5TmMtH+A@mail.gmail.com>
In-Reply-To: <CAErSpo4ErJsp5pWNLsu3x4YL9ZrtxHfk0tkYL7hZaY5TmMtH+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, 679545@bugs.debian.org, jrnieder@gmail.com

> Thanks a lot for testing this!  I'll fix up this typo and work on
> getting something like this merged.

Thank you very much!
If you want me to test anything, don't hesitate to contact me.


> What's the output of "dmesg | grep 0000:00:1f.1; lspci -vs00:1f.1"?

[    0.065506] pci 0000:00:1f.1: [8086:24cb] type 0 class 0x000101
[    0.065520] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.065531] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.065542] pci 0000:00:1f.1: reg 18: [io  0x0000-0x0007]
[    0.065553] pci 0000:00:1f.1: reg 1c: [io  0x0000-0x0003]
[    0.065564] pci 0000:00:1f.1: reg 20: [io  0x1000-0x100f]
[    0.065575] pci 0000:00:1f.1: reg 24: [mem 0x00000000-0x000003ff unset]
[    1.415250] ata_piix 0000:00:1f.1: version 2.13
[    1.415276] ata_piix 0000:00:1f.1: can't derive routing for PCI INT A
00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller  
(rev 02) (prog-if 8a [Master SecP PriP])
	Subsystem: Intel Corporation Device 3404
	Flags: bus master, medium devsel, latency 0
	I/O ports at 01f0 [size=8]
	I/O ports at 03f4 [size=1]
	I/O ports at 0170 [size=8]
	I/O ports at 0374 [size=1]
	I/O ports at 1000 [size]
	Kernel driver in use: ata_piix




Stephan




