From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 17 Apr 2002 16:58:51 +0000
Subject: Re: [Linux-ia64] Command line options to elilo from bootmanager
Message-Id: <marc-linux-ia64-105590701905471@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905469@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Richard Hirst wrote:
> 
> On Wed, Apr 17, 2002 at 09:20:50AM -0700, Michael Madore wrote:
> > Hi,
> >
> > Is it possible to pass command line options to elilo from the boot
> > manager menu?  For example, I would like to invoke elilo from the boot
> > manager with an alternate configuration file.  I tried using efibootmgr
> > like so:
> >
> > efibootmgr -L linux-ram -l "elilo.efi -C elilo-ram.conf" -c -d /dev/sda
> > -p 2"
> >
> > but apparently, EFI treats the "-C elilo-ram.conf" as part of the
> > bootloader command.
> 
> efibootmgr -c -d $BOOTDISK -p $BOOTPART -w -L "Debian GNU/Linux" \
>         -l \\EFI\\debian\\elilo.efi -u -- elilo -C \\EFI\\debian\\elilo.conf
> 
> is what I use.  The trick is to supply a dummy 'elilo' for argv[0],
> and all args after '--' are passed as arguments to elilo.efi
> 
> Richard

Thanks Richard, that works for me.

Mike

