From: Andreas Schwab <schwab@suse.de>
Date: Wed, 20 Feb 2002 17:02:44 +0000
Subject: Re: [Linux-ia64] CONFIG_USB_UHCI=y not possible?
Message-Id: <marc-linux-ia64-105590701905145@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905141@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

John Hesterberg <jh@sgi.com> writes:

|> As Bill Nottingham noted, I think it's because the USB UHCI code is
|> calling a init function from an exit function, or maybe vice versa.
|> I'm guessing that some of the err handling code in alloc_uhci is
|> somehow ending up calling uhci_pci_remove, which is defined as
|> __devexit, which gets discarded by arch/ia64/vmlinux.lds.S.  So I
|> think I've almost connected the dots. :-)

Yes, that has already been fixed in 2.4.18-rc1.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

