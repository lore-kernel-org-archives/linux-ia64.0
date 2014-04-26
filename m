From: Yijing Wang <wangyijing@huawei.com>
Date: Sat, 26 Apr 2014 02:49:24 +0000
Subject: Re: [PATCH 00/13] Refactor pci_is_brdige() to simplify code
Message-Id: <535B1EB4.3050408@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1398417515-8740-1-git-send-email-wangyijing@huawei.com> <063D6719AE5E284EB5DD2968C1650D6D0F6FEEB0@AcuExch.aculab.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6FEEB0@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: David Laight <David.Laight@ACULAB.COM>, Bjorn Helgaas <bhelgaas@google.com>
Cc: Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On 2014/4/25 17:42, David Laight wrote:
> From: Yijing Wang
>> This patchset rename the current pci_is_bridge() to pci_has_subordinate(=
),
>> and introduce a new pci_is_bridge() which determine pci bridge by check
>> dev->hdr_type. The new one is more accurate. PCIe Spec define the pci
>> device is a bridge by the dev->hdr_type =3D 0x01 || 0x02.
>=20
> That is a dangerous rename and is likely to cause difficult to

Hi David,
   I renamed pci_is_bridge() to pci_has_subordinate() because

static inline bool pci_is_bridge(struct pci_dev *pci_dev)
{
	return !!(pci_dev->subordinate);
}

which always check dev->subordinate.

> identify bugs in any code you've missed.

What are you referring to ?


Thanks!
Yijing.






>=20
> 	David
>=20
> =04=EF=BF=BD{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD+%=EF=BF=BD=EF=BF=BDlzwm=EF=BF=BD=EF=BF=BDb=EF=BF=BD=EB=A7=
=B2=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDzX=EF=BF=BD=EF=BF=BD=19=1E=EF=BF=BD=
w=EF=BF=BD=EF=BF=BD{ay=EF=BF=BD=1D=CA=87=DA=99=EF=BF=BD,j=07=EF=BF=BD=EF=BF=
=BDf=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD=1E=EF=
=BF=BDw=EF=BF=BD=EF=BF=BD=EF=BF=BD=0C=EF=BF=BD=EF=BF=BD=EF=BF=BDj:+v=EF=BF=
=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BDj=EF=BF=BDm=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=07=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDzZ+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD!=EF=BF=BDiO=EF=BF=BD=EF=BF=BDz=EF=
=BF=BD=EF=BF=BDv=EF=BF=BD^=14=04=1A=EF=BF=BD=1Bm=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=0Bn=C6=8A=EF=BF=BD=EF=BF=BDY&=EF=BF=BD
>=20


--=20
Thanks!
Yijing

