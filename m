From: =?ISO-8859-1?Q?=C9meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 24 Sep 2013 22:34:01 +0000
Subject: ACPI errors
Message-Id: <CAA9xbM5K+s1L5P+fv4vKegKSV9icsNtTzg3EQx5je2fYyUaagA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

Just noticed today, but they perhaps exist for quite some time. I'm
recording ACPI errors on my hp workstation zx6000 when booting 3.9 and
3.10 kernels (didn't try earlier kernels):

[   25.509388] libata version 3.00 loaded.
[   25.514781] ACPI Error: [LBAS] Namespace lookup failure,
AE_ALREADY_EXISTS (20130328/dswload2-330)
[   25.514884] ACPI Exception: AE_ALREADY_EXISTS, During name
lookup/catalog (20130328/psobject-222)
[   25.514965] ACPI Error: Method parse/execution failed [\LBA_.PRT_] (Node=
 e000
0040831e5af0), AE_ALREADY_EXISTS (20130328/psparse-537)
[   25.515087] ACPI Error: Method parse/execution failed [\_SB_.SBA0.PCI1._=
PRT]
(Node e0000040831e5cd0), AE_ALREADY_EXISTS (20130328/psparse-537)
[   25.515211] ACPI: Marking method _PRT as Serialized because of
AE_ALREADY_EXISTS error
[   25.515302] ACPI Error: Method execution failed [\_SB_.SBA0.PCI1._PRT] (=
Node
e0000040831e5cd0), AE_ALREADY_EXISTS (20130328/uteval-103)
[   25.515429] tg3 0000:20:02.0: can't derive routing for PCI INT A
[   25.515466] tg3 0000:20:02.0: PCI INT A: no GSI
[   25.630678] ACPI: Marking method PRT_ as Serialized because of
AE_ALREADY_EXISTS error

Can they be safely ignored? How to read them to find which devices
they refer to?

Google can find references of identical errors on other arches too.
Does it mean that there's nothing that can be done to fix them? On
some occurences, these errors were caused by kernel misconfiguration.

Thanks,

     =C9meric
