From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 10 Sep 2001 21:43:24 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805160@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I can verify this on my BigSur as well.  No USB peripherals and no
modules loaded.  Hitting the CAPS lock key causes the message and a
delay.  The keyboard LED never comes on.  This machine was recently
upgraded to BIOS 117, and also to kernel 2.4.9.

Martin Wilck wrote:
> 
> On Fri, 7 Sep 2001, KOCHI Takayoshi wrote:
> 
> > It was a BigSur with a PS/2 keyboard and a PS/2 mouse.
> > I didn't configure usb driver in the kernel nor load
> > as a module.
> 
> I have the same here with no USB on the machine at all. I think
> I had it since 2.4.7. The keyboard works fine, though - obviously
> timeouts occur randomly but usually the keyboard answers requests
> just fine.
> 
> Martin
> 
> --
> Martin Wilck                Phone: +49 5251 8 15113
> Fujitsu Siemens Computers   Fax:   +49 5251 8 20409
> Heinz-Nixdorf-Ring 1        mailto:Martin.Wilck@Fujitsu-Siemens.com
> D-33106 Paderborn           http://www.fujitsu-siemens.com/primergy
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

