From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 13 Dec 2006 20:45:05 +0000
Subject: Re: MCA in console_init()
Message-Id: <200612131345.05584.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80612081230j20db7772nfabb6e1609ea0fd8@mail.gmail.com>
In-Reply-To: <5e0a1fd80612081230j20db7772nfabb6e1609ea0fd8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 08 December 2006 13:30, Karthik Gopalakrishnan wrote:
>     I am trying to debug an MCA that I hit during kernel bootup. I
> have isolated the problem to the while loop in the console_init()
> routine called as part of start_kernel(). The IIP obtained from the
> MCA Logs point to vgacon_startup().

What sort of box is this?  Does it have a VGA device?  What console
device do you intend to use?

You probably got to vgacon_startup() as a side-effect of setting
conswitchp = &vga_con in setup_arch().

On most machines, if you poke at the VGA I/O ports and there's no VGA
device, nothing bad happens.  But some chipsets don't like that and
cause an MCA.

The MCA log should tell you what instruction you're at and what
address you tried to reference.  If you're doing an I/O port
reference, the address should be in the physical I/O port block
and you can compute the port number using the iobase address
from the EFI memory map, e.g.,

    set $iobase = 0x80000f8100000000
    set $addr = 0x80000f8100019064
    p/x ((($addr - $iobase) >> 12) << 2) | (($addr - $iobase) & 0xfff)
