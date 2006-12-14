From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Thu, 14 Dec 2006 09:23:57 +0000
Subject: Re: MCA in console_init()
Message-Id: <5e0a1fd80612140111y314acc10m4ba43443cab94d02@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5e0a1fd80612081230j20db7772nfabb6e1609ea0fd8@mail.gmail.com>
In-Reply-To: <5e0a1fd80612081230j20db7772nfabb6e1609ea0fd8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Bjorn.

On 12/14/06, Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:
> On Friday 08 December 2006 13:30, Karthik Gopalakrishnan wrote:
> >     I am trying to debug an MCA that I hit during kernel bootup. I
> > have isolated the problem to the while loop in the console_init()
> > routine called as part of start_kernel(). The IIP obtained from the
> > MCA Logs point to vgacon_startup().
>
> What sort of box is this?  Does it have a VGA device?  What console
> device do you intend to use?

It's an rx8620. It does not have a VGA device. I am trying to use a
"Virtual Console" device that a specific firmware exposes.

>
> You probably got to vgacon_startup() as a side-effect of setting
> conswitchp = &vga_con in setup_arch().

Yup. You are absolutely correct. When I compiled with
"CONFIG_VGA_CONSOLE" not set, the MCA went away. Only thing is, I
don't get console functionality since there is no entity to control
the console.

>
> On most machines, if you poke at the VGA I/O ports and there's no VGA
> device, nothing bad happens.  But some chipsets don't like that and
> cause an MCA.
>
> The MCA log should tell you what instruction you're at and what
> address you tried to reference.  If you're doing an I/O port
> reference, the address should be in the physical I/O port block
> and you can compute the port number using the iobase address
> from the EFI memory map, e.g.,
>
>     set $iobase = 0x80000f8100000000
>     set $addr = 0x80000f8100019064
>     p/x ((($addr - $iobase) >> 12) << 2) | (($addr - $iobase) & 0xfff)
>

I disassembled the code & figured that the MCA occurred in
vgcon_startup(). I didn't take a detailed look. But I think there was
an access to a MMIO region. So I guess your theory is correct. :-)

I was not familiar with the way console_initcall() routines worked. I
understand that now. The way I look at it, I'll have to write a driver
similar to "vga_con", as well as a tty driver. Thank You very much for
your help.

Thanks & Regards,
Karthik
