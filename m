From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 10 Sep 2001 22:10:24 +0000
Subject: RE: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805161@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Same test also fails in 2.4.7 ... I found a 2.4.3 kernel
still in my /boot/efi, capslock test works with that.

In 2.4.7/2.4.9 even though the caps-lock light never comes
on and the timeout message is printed, caps lock mode *is*
turned on (subsequent alphabetic chars echo in upper-case).

-Tony

-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Monday, September 10, 2001 2:43 PM
To: Martin Wilck
Cc: KOCHI Takayoshi; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] AT Keyboard not present?


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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

