From: Grant Grundler <iod00d@hp.com>
Date: Wed, 09 Mar 2005 18:48:29 +0000
Subject: Re: PCI Express
Message-Id: <20050309184829.GI10338@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Mar 09, 2005 at 12:12:37PM -0600, Colin Ngam wrote:
> The MSI address portion allows 64bits for the address.

Yes - *allows*. It also allows devices to implement 32-bit MSI address.
MSI "Control" bits indicate what is implemented.
See PCI2.2 spec or later and search for MSI.

> I am very much interested in your assertion that the MSI address is=20
> defined by PCI Spec to be 0xfeex_xxxx.
...
> Can you kindly point me to the relevent section?

It's not and it doesn't belong there.

IA64 specs defines Processor Interrupt Block and where it lives.
See "Intel=AE Itanium=AE Software Developer's Manual"
	Volume 2, Part 1, Section 5.8.4
	Volume 2, Part 1, Section 11.9.3


grant
