From: Rolf Eike Beer <eike-hotplug@sf-tec.de>
Date: Thu, 19 May 2005 07:56:08 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <200505191000.59750@bilbo.math.uni-mannheim.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart3756225.LMbbGZWsnW"
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
To: linux-ia64@vger.kernel.org

--nextPart3756225.LMbbGZWsnW
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Prarit Bhargava wrote:
> Prarit Bhargava wrote:
> > Prarit Bhargava wrote:
> >>> D_B_S alone should be a unique identifier, so please don't use
> >>> anything more if you don't need it to make the slot name unique.
> >>
> >> On Altix, since the system can be cabled in a number of ways a pointer
> >> to the rack ID is definately useful and helps to uniquely identify the
> >> slot.  I'm going to use a 2 digit rack id, followed by the DDDD:BB:SS
> >> value.
> >
> > Err .. uh .. unless there are any strenous objections of course ;

> New patch after comments from Eike and Greg.

Something I missed in the previous patch:

+static int sn_hp_slot_private_alloc(struct hotplug_slot *bss_hotplug_slot,
+                                   struct pci_bus *pci_bus, int device)
+{
+       struct pcibus_info *pcibus_info;
+       struct slot *slot;
+
+       pcibus_info =3D SN_PCIBUS_BUSSOFT_INFO(pci_bus);
+
+       bss_hotplug_slot->private =3D kcalloc(1, sizeof(struct slot),
+                                           GFP_KERNEL);
+       if (!bss_hotplug_slot->private)
+               return -ENOMEM;
+       slot =3D bss_hotplug_slot->private;
+

Better do it this way:

slot =3D kcalloc(1, sizeof(*slot), GFP_KERNEL);
bss_hotplug_slot->private =3D slot;

This way the size of the memory area is always the correct one (which is th=
e=20
preferred way of operating *g*).

I think it's really time for something like kmalloc0() or whatever to stop=
=20
this type of kcalloc() abuse.

Eike

--nextPart3756225.LMbbGZWsnW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBCjEe7XKSJPmm5/E4RAi+NAKCJnSv6dEjyEIXb19kyorsg78PvowCdETL8
TjACmpuSoeE+v6VILk5ay40=
=k+Jk
-----END PGP SIGNATURE-----

--nextPart3756225.LMbbGZWsnW--
