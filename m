From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Mon, 27 Sep 2004 16:53:48 +0000
Subject: Re: [ACPI] PATCH-ACPI based CPU hotplug[2/6]-ACPI Eject interface support
Message-Id: <20040927095348.A29594@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040920092520.A14208@unix-os.sc.intel.com> <200409201812.45933.dtor_core@ameritech.net> <20040924162823.B27778@unix-os.sc.intel.com> <200409270112.29422.dtor_core@ameritech.net>
In-Reply-To: <200409270112.29422.dtor_core@ameritech.net>; from dtor_core@ameritech.net on Mon, Sep 27, 2004 at 01:12:28AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Dmitry Torokhov <dtor_core@ameritech.net>
Cc: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>, Len Brown <len.brown@intel.com>, acpi-devel@lists.sourceforge.net, LHNS list <lhns-devel@lists.sourceforge.net>, Linux IA64 <linux-ia64@vger.kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Sep 27, 2004 at 01:12:28AM -0500, Dmitry Torokhov wrote:
> On Friday 24 September 2004 06:28 pm, Keshavamurthy Anil S wrote:
> > +typedef void acpi_device_sysfs_files(struct kobject *,
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0const struct attribute *);
> > +
> > +static void setup_sys_fs_device_files(struct acpi_device *dev,
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0acpi_device_sysfs_files *=
func);
> > +
> > +#define create_sysfs_device_files(dev)=A0\
> > +=A0=A0=A0=A0=A0=A0=A0setup_sys_fs_device_files(dev, (acpi_device_sysfs=
_files *)&sysfs_create_file)
> > +#define remove_sysfs_device_files(dev)=A0\
> > +=A0=A0=A0=A0=A0=A0=A0setup_sys_fs_device_files(dev, (acpi_device_sysfs=
_files *)&sysfs_remove_file)
>=20
>=20
> Hi Anil,
>=20
> It looks very nice except for the part above. I am really confused what t=
he
> purpose of this code is... It looks like it just complicates things?
Hi Dmitry,
	I just wanted to have a single function i.e setup_sys_fs_device_files() fo=
r both
creating and removing sysfs files. So I have #defined create_sysfs_device_f=
iles() and=20
remove_sysfs_device_files() and one of the arguments to the setup_sys_fs_de=
vice_files()
is a function pointer, i.e for one it takes sysfs_create_file and for other=
 it takes
sysfs_remove_file.

Having single function for creating and removing sysfs files make it easy=20
from the maintaince perspective, as oppose to remember to code for remove=20
as well when one adds the new file.


thanks,
Anil
