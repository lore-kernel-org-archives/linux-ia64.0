From: Rolf Eike Beer <eike-hotplug@sf-tec.de>
Date: Fri, 13 May 2005 08:03:10 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver - SN Hotplug Driver code
Message-Id: <200505131003.18143@bilbo.math.uni-mannheim.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1510303.PiPpOlV8VM"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--nextPart1510303.PiPpOlV8VM
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Prarit Bhargava wrote:
> This patch is the SGI hotplug driver and additional changes required for
> the driver.  These modifications include changes to the SN io_init.c code
> for memory management, the inclusion of new SAL calls to enable and disab=
le
> PCI slots, and a hotplug-style driver.
>
> Signed-off-by: Prarit Bhargava <prarit@sgi.com>

> Index: drivers/pci/hotplug/sgi_hotplug.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null  (tree:94b3c225a19fb0e688da58fa7c9239db0a743e9c)
> +++
> d42322aa13214a5d099019ff0406dfb328960b98/drivers/pci/hotplug/sgi_hotplug.=
c=20
> (mode:100644 sha1:323041fd41dc19c20ce88e4ae370272cbe09ea97)

> +static int sn_hp_slot_private_alloc(struct hotplug_slot *bss_hotplug_slo=
t,
> +				    struct pci_bus *pci_bus, int device)
> +{
> +	struct pcibus_info *pcibus_info;
> +	struct slot *slot;
> +
> +	pcibus_info =3D SN_PCIBUS_BUSSOFT_INFO(pci_bus);
> +
> +	bss_hotplug_slot->private =3D kcalloc(1, sizeof(struct slot),
> +					    GFP_KERNEL);
> +	if (!bss_hotplug_slot->private)
> +		return -ENOMEM;
> +	slot =3D (struct slot *)bss_hotplug_slot->private;

Please remove this cast. Since private is a void* there is never a cast nee=
ded=20
to or from this.

> +	bss_hotplug_slot->name =3D kmalloc(33, GFP_KERNEL);

I would feel better if you would use a #define here like the other drivers =
do.=20
They normally name is SLOT_NAME_SIZE or something similar.

> +	sprintf(bss_hotplug_slot->name, "module_%c%c%c%c%.2d_b_%d_s_%d",
> +		'0'+RACK_GET_CLASS(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> +		'0'+RACK_GET_GROUP(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> +		'0'+RACK_GET_NUM(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
> +		MODULE_GET_BTCHAR(pcibus_info->pbi_moduleid),
> +		MODULE_GET_BPOS(pcibus_info->pbi_moduleid),
> +		((int)pcibus_info->pbi_buscommon.bs_persist_busnum) & 0xf,
> +		device + 1);

*eek* Sorry, but that looks really ugly. Wouldn't it be enough do name it l=
ike=20
the device that would be in slot, something like DOMAIN_BUS_SLOT and maybe=
=20
one extra number?

> +static struct hotplug_slot * sn_hp_destroy(void)

Please remove the space before the function name

> +static u8 sn_power_status_get(struct hotplug_slot *bss_hotplug_slot)

Why not do this few instructions in get_power_status() directly? Or at leas=
t=20
mark it inline, you only use it once and it does not really consume much=20
stack space.

> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Remove cast.

> +static void sn_slot_mark_enable(struct hotplug_slot *bss_hotplug_slot,
> +				int device_num)

Add inline or inline it by hand.

> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Cast.

> +static void sn_slot_mark_disable(struct hotplug_slot *bss_hotplug_slot,
> +				 int device_num)
> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

The same.

> +static int sn_slot_enable(struct hotplug_slot *bss_hotplug_slot,
> +			  int device_num)
> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Cast.

> +	if (rc =3D=3D PCI_SLOT_ALREADY_UP) {
> +		dev_dbg(slot->pci_bus->self, "is already active\n");
> +		return -EPERM;
> +	}

IIRC most other drivers handle this case as success. Greg, your opinion?

> +	if (rc) {
> +		dev_dbg(slot->pci_bus->self,
> +			"insert failed with error %d sub-error %d\n",
> +			rc, resp.resp_sub_errno);
> +		return -EIO;
> +	}
> +
> +	sn_slot_mark_enable(bss_hotplug_slot, device_num);
> +
> +	return 0;
> +}

Replacing the last function call with 4 lines of instructions won't hurt I=
=20
think. IMHO sn_slot_mark_enable() should be killed. Maybe you add a comment=
=20
here to tell what's going on if you want to make it clear.

> +static int sn_slot_disable(struct hotplug_slot *bss_hotplug_slot,
> +			   int device_num, int action)
> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Cast.

> +	if (action =3D=3D PCI_REQ_SLOT_ELIGIBLE && rc =3D=3D PCI_SLOT_ALREADY_D=
OWN) {

I would feel better if you add extra braces around the tests, but I'm proba=
bly=20
just a bit paranoid about this things. Greg?

> +		dev_dbg(slot->pci_bus->self, "Slot %s already inactive\n");
> +		return -ENODEV;
> +	}

Again this might better be a success.

> +	if (action =3D=3D PCI_REQ_SLOT_DISABLE && rc) {
> +		dev_dbg(slot->pci_bus->self,"remove failed rc =3D %d\n", rc);
> +		return rc;
> +	}
> +
> +	return rc;
> +}

One return should be enough for everyone.

> +static int enable_slot(struct hotplug_slot *bss_hotplug_slot)
> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Cast.

> +	num_funcs =3D pci_scan_slot(slot->pci_bus, PCI_DEVFN(slot->device_num+1,

Add spaces before and after '+'. I don't feel good with this "+1" at all, t=
his=20
is some kind of strange.

> +							   PCI_FUNC(0)));

Greg, what do you think. Isn't just 0 better here?

Please wrap the line one level higher and keep the second argument as one, =
so=20
add the break behind "slot->pci_bus,".

> +static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
> +{
> +	struct slot *slot =3D (struct slot *)bss_hotplug_slot->private;

Cast.

> +static int get_power_status(struct hotplug_slot *bss_hotplug_slot, u8
> *value) +{
> +	down(&sn_hotplug_sem);
> +	*value =3D sn_power_status_get(bss_hotplug_slot);
> +	up(&sn_hotplug_sem);
> +	return 0;
> +}

sn_power_status_get() should be easily be inlinable to here. This would all=
ow=20
to make the up()/down() protect even less instructions.

> +static int sn_hotplug_slot_register(struct pci_bus *pci_bus)
> +{
> +	int device;
> +	struct hotplug_slot *bss_hotplug_slot;
> +	int rc =3D 0;
> +
> +	/*
> +	 * Currently only four devices are supported,
> +	 * in the future there maybe more -- up to 32.
> +	 */
> +
> +	for (device =3D 0; device < SN_MAX_HP_SLOTS ; device++) {
> +		if (sn_pci_slot_valid(pci_bus, device) !=3D 1)
> +			continue;
> +
> +		bss_hotplug_slot =3D kcalloc(1,sizeof(struct hotplug_slot),
> +					   GFP_KERNEL);

Use "sizeof(*bss_hotplug_slot)" and add a space after the ','.

> +		bss_hotplug_slot->info =3D
> +			kcalloc(1,sizeof(struct hotplug_slot_info),
> +				GFP_KERNEL);

Same here.

> +static int sn_pci_hotplug_init(void)
> +{

> +		if (!rc)
> +			registered =3D 1;
> +		else {
> +			registered =3D 0;
> +			break;
> +		}

Please use {} for the if also to make it look saner.

Eike

--nextPart1510303.PiPpOlV8VM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBChF9GXKSJPmm5/E4RAlbmAJ0d7YpZ2lQCRHkLukbgBd7kQI4kCwCgmaIO
tHveAyJhBilFr0UUY+ukwCc=
=/ya/
-----END PGP SIGNATURE-----

--nextPart1510303.PiPpOlV8VM--
