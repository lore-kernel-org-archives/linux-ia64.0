From: Johannes Erdfelt <jerdfelt@valinux.com>
Date: Fri, 14 Jul 2000 23:39:37 +0000
Subject: Re: [Linux-ia64] issues of Linux 2.3.99 installed on BigSur EFI 1.00 [12.15]
Message-Id: <marc-linux-ia64-105590678205200@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205194@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205194@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 11, 2000, yiding_wang@agilent.com <yiding_wang@agilent.com> wrote:
> We have two BigSur system experiencing hard time on Linux 2.3.99 scsi
> interface:
> -------------------------
> System #1:
> Configuration  - EFI 1.00 [12.15], upgrade by Intel from A-1 stepping to A-3
> stepping
>                         Qlogic BIOS 1.15
>                         Qla1280 Firmware 8.13.08
>                         1GB RAM, 9GB scsi hard drive
> Problem - System booted fine and most IO test OK before the upgrade.  After
> upgrade,
>                BIOS can see the scsi device
>                EFI also see the files on the drive
>                "eli vmlinux root=/dev/sda3" will fail due to cannot found
> /dev/sda3
>                Tried other possible device node but none of them works.
>                Re-install Linux 2.3.99 (TurboLinux) also failed on the same
> problem.

ELI does not attempt to understand the root partition. It's simply passed
to the kernel which then attempts some magic.

I assume that the kernel gives an error message that it cannot find the
device?

> Note: for system #1, windows2000 64 installation and running OK!
> ----------------------------------
> System #2:
> Configuration  - EFI 0.99 [12.25], A-2 stepping
>                         Qlogic BIOS 1.15
>                         Qla1280 Firmware 8.13.08
>                         1GB RAM, 9GB scsi hard drive
> Problem - System failed during the boot.  All scsi command timed out and
> aborted after
>                BIOS, EFI and eli sees the device.
> -----------------------------------
> 
> Is anyone can help on these issues?
> 
> Also could someone explain a little bit about the EFI and eil loading
> process, what are they stand for and basic function among BIOS, EFI and eli?
> 
> Many thanks!

ELI stands for EFI Linux Loader. It's similar to LILO, but is specific to
ia64 (for now) and EFI.

It doesn't use the BIOS at all. It uses EFI to load the image for the
kernel (usually the hard drive) and obtains configuration information (IRQ
routing) and some other tables, frees memory (both from ELI and EFI) then
executes the kernel.

The kernel should atleast start to boot. Getting any error messages from
you would be very useful to try to troubleshoot the problem you're seeing.

JE



