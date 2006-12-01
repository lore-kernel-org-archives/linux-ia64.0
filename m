From: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
Date: Fri, 01 Dec 2006 23:28:14 +0000
Subject: Re: [PATCH] Add support for type argument in PAL_GET_PSTATE
Message-Id: <20061201152814.A6836@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061101103500.A16140@unix-os.sc.intel.com>
In-Reply-To: <20061101103500.A16140@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: jes@trained-monkey.org [mailto:jes@trained-monkey.org] On Behalf
> Of Jes Sorensen
> Sent: Friday, December 01, 2006 8:39 AM
> To: Pallipadi, Venkatesh
> Cc: Luck, Tony; linux-ia64@vger.kernel.org
> Subject: Re: [PATCH] Add support for type argument in PAL_GET_PSTATE
>=20
> >>>>> "Jes" =3D Jes Sorensen <jes@sgi.com> writes:
>=20
> Jes> Hi Venkatesh,
>=20
> Jes> Please respect the previous formatting of the file and not add
> Jes> pointless parenthesises around the constants like that.
>=20
> I read the date of the posting as Dec 1 not Nov 1 - so a bit
> old. Point is still valid though.
>=20

Agreed..

Below is the updated patch.=20

Thanks,
Venki


PAL_GET_PSTATE accepts a type argument to return different kinds of
frequency information.
Refer: Intel Itanium=AEArchitecture Software Developer's Manual -=20
Volume 2: System Architecture, Revision 2.2
(http://developer.intel.com/design/itanium/manuals/245318.htm)

Add the support for type argument and use Instantaneous frequency
in the acpi driver.

Also fix a bug, where in return value of PAL_GET_PSTATE was getting compared
with 'control' bits instead of 'status' bits.

Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>

Index: linux-2.6.19-rc-mm/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.19-rc-mm.orig/arch/ia64/kernel/cpufre=
q/acpi-cpufreq.c
+++ linux-2.6.19-rc-mm/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -68,7 +68,8 @@ processor_get_pstate (
=20
 	dprintk("processor_get_pstate\n");
=20
-	retval =3D ia64_pal_get_pstate(&pstate_index);
+	retval =3D ia64_pal_get_pstate(&pstate_index,
+	                             PAL_GET_PSTATE_TYPE_INSTANT);
 	*value =3D (u32) pstate_index;
=20
 	if (retval)
@@ -91,7 +92,7 @@ extract_clock (
 	dprintk("extract_clock\n");
=20
 	for (i =3D 0; i < data->acpi_data.state_count; i++) {
-		if (value >=3D data->acpi_data.states[i].control)
+		if (value =3D data->acpi_data.states[i].status)
 			return data->acpi_data.states[i].core_frequency;
 	}
 	return data->acpi_data.states[i-1].core_frequency;
@@ -117,11 +118,7 @@ processor_get_freq (
 		goto migrate_end;
 	}
=20
-	/*
-	 * processor_get_pstate gets the average frequency since the
-	 * last get. So, do two PAL_get_freq()...
-	 */
-	ret =3D processor_get_pstate(&value);
+	/* processor_get_pstate gets the instantaneous frequency */
 	ret =3D processor_get_pstate(&value);
=20
 	if (ret) {
Index: linux-2.6.19-rc-mm/include/asm-ia64/pal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.19-rc-mm.orig/include/asm-ia64/pal.h
+++ linux-2.6.19-rc-mm/include/asm-ia64/pal.h
@@ -80,6 +80,11 @@
 #define PAL_SET_PSTATE		263	/* set the P-state */
 #define PAL_BRAND_INFO		274	/* Processor branding information */
=20
+#define PAL_GET_PSTATE_TYPE_LASTSET	0
+#define PAL_GET_PSTATE_TYPE_AVGANDRESET	1
+#define PAL_GET_PSTATE_TYPE_AVGNORESET	2
+#define PAL_GET_PSTATE_TYPE_INSTANT	3
+
 #ifndef __ASSEMBLY__
=20
 #include <linux/types.h>
@@ -1112,10 +1117,10 @@ ia64_pal_halt_info (pal_power_mgmt_info_
=20
 /* Get the current P-state information */
 static inline s64
-ia64_pal_get_pstate (u64 *pstate_index)
+ia64_pal_get_pstate (u64 *pstate_index, unsigned long type)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL_STK(iprv, PAL_GET_PSTATE, 0, 0, 0);
+	PAL_CALL_STK(iprv, PAL_GET_PSTATE, type, 0, 0);
 	*pstate_index =3D iprv.v0;
 	return iprv.status;
 }
