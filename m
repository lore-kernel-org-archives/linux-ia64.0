From: Andreas Schwab <schwab@suse.de>
Date: Fri, 14 Nov 2003 15:53:07 +0000
Subject: Re: drivers/usb/core/config.c: invalid configuration descriptor
Message-Id: <marc-linux-ia64-106882521025576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106865176701709@msgid-missing>
In-Reply-To: <marc-linux-ia64-106865176701709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>>> On Fri, 14 Nov 2003 14:03:04 +0100, Andreas Schwab <schwab@suse.de> =
said:
>
>   Andreas> Andreas Schwab <schwab@suse.de> writes:
>   >> When I try to run 2.6.0-test9 on an HP Everest I can't get USB
>   >> working.  All I get is this:
>
>   >> drivers/usb/core/usb.c: registered new driver hub PCI: Found IRQ
>   >> 52 for device 0000:01:04.0 IOSAPIC: vector 52 -> CPU 0x0200,
>   >> enabled ohci_hcd 0000:01:04.0: OHCI Host Controller ohci_hcd
>   >> 0000:01:04.0: irq 52, pci mem c000000088032000 ohci_hcd
>   >> 0000:01:04.0: new USB bus registered, assigned bus number 1
>   >> drivers/usb/core/config.c: invalid configuration descriptor
>
>   Andreas> This is actually a compiler bug, usb_parse_configuration
>   Andreas> gets miscompiled.
>
> Interesting.  Which compiler?

Nothing of interest, only some broken local changes.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
