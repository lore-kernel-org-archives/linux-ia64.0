From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 10 Dec 2007 18:33:07 +0000
Subject: Re: Linux on Intel "Big Sur"
Message-Id: <200712101133.08116.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <475C2CF3.9010206@netbynet.ru>
In-Reply-To: <475C2CF3.9010206@netbynet.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday 09 December 2007 10:59:15 am Alexei Gerasimov wrote:
> I happen to posses an old "Big Sur" machine manufactured by Intel, based
> around two Itanium (Merced) CPU's and a 460GX chipset. The machine is
> labeled as an "enginnering sample" (label:
> http://ishells.net/spy/itanium/DSC00873.jpg), and looks identical to the
> HP i2000 workstation (picture: http://ishells.net/spy/itanium/DSC00880.jpg).
> 
> I have faced a problem of getting an operating system for it. Namely,
> Linux. I have tried installing both Debian 3.0r6 Woody and Debian 4.0r1
> Etch, however, the CD kernel doesn't succeed to boot. Somewhere after
> probing for USB and SCSI devices, the video signal is lost (monitor
> switches into a stand-by mode), and nothing else happens. Since I'm
> using some old Matrox graphics card, I thought it could be a problem
> with framebuffer, but disabling the framebuffer didn't help.
> 
> On the Debian website, it's stated that there could be problems due to
> old BIOS/firmware versions. Here's what I've got:
> 
> BIOS: W460GXBS2.86E.0117C.P09.200108091154
> SMBIOS: 2.3.1
> 
> PAL (A/B): 6623/6625
> SAL (A/B): 101/101
> Boot Block: 30
> 
> There are BIOS and firmware updates for i2000 available on the HP
> website, but I'm not sure if they are compatible with my machine, and am
> afraid of damaging either BIOS or firmware at updating attempt.
> 
> Do you reckon it is safe to update? What else would you suggest me to do
> about my machine to succeed with Linux installation? And is it possible
> to run HP-UX 11i (probably v1.5/1.6/2.0) on it?

I've only used the HP i2000 version, and even that's been a long time,
but my guess is that the firmware upgrade would be safe, and that the
appropriate HP-UX version would probably run on it.

If you want to debug the Linux problem, you might try using a serial
console (try something like "console=uart,io,0x3f8,9600n8" or
"console=uart,io,0x2f8,9600n8"), adding some debug options
("debug initcall_debug") and booting to single-user mode
("single" or "init=/bin/bash").

Bjorn
