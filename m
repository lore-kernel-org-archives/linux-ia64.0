From: Andreas Schwab <schwab@suse.de>
Date: Tue, 25 Jan 2005 15:21:45 +0000
Subject: Questionable code in pci_sal_read
Message-Id: <jek6q1o7p2.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

These are the first few lines in pci_sal_read:

	if ((seg > 255) || (bus > 255) || (devfn > 255) || (reg > 4095))
		return -EINVAL;

	if ((seg | reg) <=3D 255) {

When seg <=3D 255 then ((seg | reg) <=3D 255) is equivalent to (reg <=3D 25=
5).
But pci_sal_write only rejects (seg > 65535).

The lines come from this changeset:

http://linux.bkbits.net:8080/linux-2.6/cset%40407c8325V8ZAIQkFDRCUNpu5AXqG1g

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
