From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 13 Apr 2004 14:34:49 +0000
Subject: Re: oops in serial_out in 2.6.5
Message-Id: <1081866888.2775.13.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413063757.GA11350@hp.com>
In-Reply-To: <20040413063757.GA11350@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


   What's in your /var/lib/setserial/autoserial.conf?  What does the
kernel print out for serial ports on bootup?  I'm guessing they're out
of sync.  It would be nice if we could stop the oops, but I'm guessing
the quicker fix is to reconfigure setserial to "kernel" configuration.=20
Your ttyS0 on irq 49 is likely the builtin UART, not the MP UART.  If
that fixes it, please report back the differences in config versus
kernel serial port listings.  Thanks,

	Alex

On Tue, 2004-04-13 at 00:37, Martin Pool wrote:
> I'm (trying to) run Debian's 2.6.5-mckinley-smp on an hp rx2600.  It
> oopses at startup in setserial.  The console is ttyS0, which points to
> the management processor.
>=20
> Loading the saved-state of the serial devices...
> Cannot set serial info: Device or resource busy
> /dev/ttyS0 at 0x0000 (irq =3D 49) is a 16550A
> /dev/ttyS1 at 0x0000 (irq =3D 60) is a 16550A
> Unable to handle kernel NULL pointer dereferencesetserial[203]: Oops 8804=
682956800 [1]
>       =20
> Pid: 203, CPU 0, comm:            setserial
> psr : 0000101008026018 ifs : 800000000000040a ip  : [<a0000001002b8690>] =
   Tainted: GF
> ip is at serial_out+0xb0/0x1a0
> unat: 0000000000000000 pfs : 000000000000038a rsc : 0000000000000003
> rnat: 0000000000000040 bsps: e0000040fe1e4680 pr  : a400000000169965
> ldrs: 0000000000000000 ccv : 0000000000000002 fpsr: 0009804c0270033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a0000001002bc890 b6  : a000000100002d70 b7  : a0000001002bc340
> f6  : 1003ecccccccccccccccd f7  : 000000000000000000000
> f8  : 1003e000000000101426b f9  : 1003e0000000005064c17
> f10 : 1003e0000000051eb851f f11 : 1003e0000000000080000
> r1  : a000000100790000 r2  : 0000000000000002 r3  : 0000000000000000
> r8  : a0000001006b9373 r9  : a0000001006b9372 r10 : a000000100642820
> r11 : a000000100642820 r12 : e00000405142fd70 r13 : e000004051428000
> r14 : e00000405142fd80 r15 : a0000001006b9360 r16 : 0000000000000002
> r17 : 0010000000000000 r18 : 0000000000000001 r19 : 0000000000000002
> r20 : 0000000000000001 r21 : 0000000000000000 r22 : 0000000000000000
> r23 : a0000001006428f8 r24 : a0000001006b935c r25 : a000000100642820
> r26 : a000000100642820 r27 : e0000040509b3ab0 r28 : e00000405142fd88
> r29 : e0000040509b3aa8 r30 : 0000000000000001 r31 : e00000405142fd84
>                                                                     =20
> Call Trace:
>  [<a000000100019800>] show_stack+0x80/0xa0
>                                 sp=E00000405142f940 bsp=E0000040514292f8
>  [<a00000010003f910>] die+0x190/0x260
>                                 sp=E00000405142fb10 bsp=E0000040514292c0
>  [<a000000100059e80>] ia64_do_page_fault+0x1e0/0x980
>                                 sp=E00000405142fb10 bsp=E000004051429258
>  [<a000000100011d20>] ia64_leave_kernel+0x0/0x280
>                                 sp=E00000405142fba0 bsp=E000004051429258
>  [<a0000001002b8690>] serial_out+0xb0/0x1a0
>                                 sp=E00000405142fd70 bsp=E000004051429208
>  [<a0000001002bc890>] serial8250_startup+0x550/0x6c0
>                                 sp=E00000405142fd70 bsp=E0000040514291c8
>  [<a0000001002af980>] uart_startup+0x240/0x4e0
>                                 sp=E00000405142fd70 bsp=E000004051429178
>  [<a0000001002b1cf0>] uart_set_info+0x3f0/0xb20
>                                 sp=E00000405142fd90 bsp=E000004051429090
>  [<a0000001002b39f0>] uart_ioctl+0x2f0/0x3a0
>                                 sp=E00000405142fe20 bsp=E000004051429048
>  [<a0000001002841d0>] tty_ioctl+0x870/0xa60
>                                 sp=E00000405142fe20 bsp=E000004051428ff0
>  [<a000000100159850>] sys_ioctl+0x350/0x820
>                                 sp=E00000405142fe20 bsp=E000004051428f60
>  [<a000000100011b80>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E00000405142fe30 bsp=E000004051428f60
>  /dev/ttyS2 at 0x0000 (irq =3D 57) is a 16550A
> /etc/rcS.d/S46setserial: line 152:   203 Segmentation fault      ${SETSER=
IAL} -z $device $args
> =20
>=20
>=20
> In case it helps here are some of the TOC dump fields:
>=20
> <6>Entered OS INIT handler. PSP=FFe301a0
> Delaying for 5 seconds...
> NaT bits        0000000000000000
> pr              80000001ff606ca9
> b0              a000000100018b90 ia64_pal_call_static+0x70/0xa0
> ar.rsc          0000000000000003
> cr.iip          e00000003fae0da2 0xe00000003fae0da2
> cr.ipsr         0000141008020018
> cr.ifs          8000000000003060
> xip             a000000100018ba0 ia64_pal_call_static+0x80/0xa0
> xpsr            0000101008026018
> xfs             8000000000003060
> b1              80000000ffe0d3d0 0x80000000ffe0d3d0
>=20
> Backtrace of pid 204 (setserial)
>                                 =20
> Call Trace:
>  [<a000000100087520>] schedule+0x1080/0x1720
>                                 sp=E00000405142fda0 bsp=E000004051429208
>  [<a0000001000398e0>] __down_interruptible+0x280/0x460
>                                 sp=E00000405142fdb0 bsp=E000004051429190
>  [<a0000001002b57a0>] uart_get+0x340/0x380
>                                 sp=E00000405142fde0 bsp=E000004051429148
>  [<a0000001002b5860>] uart_open+0x80/0x320
>                                 sp=E00000405142fde0 bsp=E000004051429100
>  [<a000000100281ad0>] tty_open+0x550/0x8a0
>                                 sp=E00000405142fde0 bsp=E000004051429098
>  [<a000000100140b30>] chrdev_open+0x390/0x700
>                                 sp=E00000405142fdf0 bsp=E000004051429038
>  [<a000000100125560>] dentry_open+0x3a0/0x5a0
>                                 sp=E00000405142fe00 bsp=E000004051428fb8
>  [<a0000001001251a0>] filp_open+0xc0/0xe0
>                                 sp=E00000405142fe00 bsp=E000004051428f88
>  [<a000000100126030>] sys_open+0xb0/0x140
>                                 sp=E00000405142fe30 bsp=E000004051428f08
>  [<a000000100011b80>] ia64_ret_from_syscall+0x0/0x20
>                                 sp=E00000405142fe30 bsp=E000004051428f08
>                                                                          =

> INIT dump complete.  Please reboot now.
--=20
Alex Williamson                             HP Linux & Open Source Lab

