From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 03 Feb 2010 23:56:35 +0000
Subject: Re: linux-ia64 crashes with two itanium2 plugged
Message-Id: <201002031656.35584.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <27379296.post@talk.nabble.com>
In-Reply-To: <27379296.post@talk.nabble.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 02 February 2010 12:36:33 am trouthy_61x65 wrote:
> 
> Hi all, I try to install a Linux SLESuse10 or Debian5 onto a computer with
> Supermicro's motheboard and Itanium2 based. With once processor Linux-ia64
> perfectly runs up but when i plug the second processor the O.S. crashes.
> Then i tried to re-install it or boot with failsafe mode without good
> result; during the hardware detect or after it it crashes and reboot. I had
> to unplug the second processor and remake the entire installation. Actually
> I take some informations about re-compilation of the kernel but i found
> nothing about that problem. Has anybody got any idea? Thanks (I watched a
> message during the crashes such "number of slaves reached..." i also
> replaced the twin itanium2 proc)

If you can collect a serial console log, or write down the OS crash
information by hand, or even take a video of the crash, it will help
give us some idea of where to look.

Bjorn
