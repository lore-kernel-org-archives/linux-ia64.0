From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 01 Sep 2004 15:14:45 +0000
Subject: Re: HCDP concerns
Message-Id: <200409010914.45574.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4135A3A7.9000706@bull.net>
In-Reply-To: <4135A3A7.9000706@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wednesday 01 September 2004 4:25 am, Xavier Bru wrote:
> I have some concerns with using kernel 2.6.8.1 (and 2.6.7) with our=20
> platform that has a new BIOS that provides HCDP.

Great!  I'm thrilled that non-HP boxes are starting to provide the HCDP!
If there's still time to change, you might consider implementing the
PCDP, as it is significantly improved.

> 1) When kernel is configured without h/pcdp support ( CONFIG_EFI_PCDP is =

> not set),
> the serial console are not initialized (efi.hcdp is not NULL).

I'm not quite sure what the problem is here.  Were you hoping that even
without CONFIG_EFI_PCDP, we would notice that efi_uart_console_only()
is true, and just default to a serial console?  That would be nice, but
I don't think the EFI console path contains enough information to directly
locate the UART device early in boot  (In general, you need PCI enumeration
or ACPI namespace access to interpret device paths.)

> A simple fix could be:
> --- linux-2.6.8.1-ori/arch/ia64/kernel/setup.c    2004-08-14=20
> 12:54:50.000000000 +0200
> +++ linux-2.6.8.1/arch/ia64/kernel/setup.c    2004-08-31=20
> 11:54:02.000000000 +0200
> @@ -351,9 +351,9 @@
>  #endif
>  #ifdef CONFIG_EFI_PCDP
>      efi_setup_pcdp_console(*cmdline_p);
> +    if (!efi.hcdp)
>  #endif
>  #ifdef CONFIG_SERIAL_8250_CONSOLE
> -    if (!efi.hcdp)
>          setup_serial_legacy();
>  #endif

The "assume ports are at 0x3f8 and 0x2f8" approach is dangerous
(because we'll poke at things that might not exist), and I don't
want to do any more of that than we have to.

My expectation is that CONFIG_EFI_PCDP would always be enabled;
I'm not aware of any downside to that, even if the platform doesn't
supply an HCDP or PCDP.

> 2) Our platform has 2 serial ports (let say port 0 at address 3f8, port=20
> 1 at address 2f8). Usually port 0 is seen as ttyS0 & port 1 as ttyS1.=20
> EFI console redirection is done on port S1 (2f8) & is described through=20
> HCDP(port 0 is not described).
> Using the h/pcdp support ( CONFIG_EFI_PCDP=3D1), we get some strange=20
> behaviours:
> . "console=3DttyS0" boot parameter, as explained in menuconfig takes the =

> HCDP table entry as console, but changes the ttyS* order:
> ttyS1 for port 0 (3f8) and ttyS0 for port 1 (2f8). Console is OK,  but=20
> the ttyS0 on port 1 is confusing compared to kernels without hcdp support.

Yes, I agree this is broken.  The ttySx device names should stay the
same, regardless of whether PCDP is present, or whether we look at it.

I posted patches to fix this a long time ago, but it involved too many
changes to the serial driver.  I have some ideas about how to improve
this, so your interest will prod me to pursue them.

> . due to this behaviour, there is no more possibility to have the linux=20
> console redirection on the port 0 at boot time.

I don't understand what this is.  Can you explain further?

> . My understanding was that h/pcdp support should provide some new=20
> console=EFi (or serial)  option to have the console defined by efi used=20
> by linux as console, but that this should not change the ttyS order, and =

> that we should still be able to use console=3D"ttySx" at boot time to hav=
e=20
> the console on port "x".

If your BIOS supplies a PCDP and you set CONFIG_EFI_PCDP, you should
not have to use a "console=3D" option at all.

Even if you only have an HCDP, you don't have to use a "console=3D"
option if ConOut contains only UARTs and you're using the default
baud rate.  We'll just default to the first HCDP entry.

> . specifying no "console=3D" provides no console as the Conout variable i=
s=20
> not exported by EFI at runtime. Should it be ?

I think it makes sense that ConOut should be available for runtime access,
but I can't point to a reference in the spec.  All the platforms I've seen
do make it available for runtime access.

We currently look at ConOut only when we have an HCDP.  If the BIOS
supplies a PCDP, there's no need to look at ConOut.
