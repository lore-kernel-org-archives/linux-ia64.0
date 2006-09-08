From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 08 Sep 2006 01:20:01 +0000
Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <08B1877B2880CE42811294894F33AD5C053BFA@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Takao Indoh
> Sent: 2006=C4=EA9=D4=C27=C8=D5 22:49
> To: Yu, Luming
> Cc: fastboot@lists.osdl.org; Keith Owens; linux-ia64@vger.kernel.org
> Subject: RE: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
>=20
> On Thu, 7 Sep 2006 21:01:17 +0800, "Yu, Luming" wrote:
>=20
> >>>Did  saved Os gp in SAL OS state  somehow get overridden before
> >>>ia64_set_kernel_registers prior to invocation of ia64_init_handler?
> >>>
> >>>I assume the following code (in ia64_set_kernel_registers )
> >>should restore
> >>>correct GP value.
> >>>
> >>>ia64_set_kernel_registers:
> >>>	...
> >>>        ;;
> >>>        ld8 r1=3D[temp4]          // OS GP from SAL OS state
> >>
> >>Yes, but this gp value is physical address.
> >>In the next line, gp is changed to virtual address.
> >>
> >>DATA_PA_TO_VA(r1,temp1)
> >>
> >>This macro just sets region7 bit, so gp value becomes region7 address.
> >
> >Ok, could you please confirm what is the value of r1 before
> >DATA_PA_TO_VA(r1, temp1)?
> >I guess we need to set r1 =3D __gp in ia64_set_kernel_registers.
> >If not,  this is a bug.  Am I right?
>=20
> In the ia64_mca_init, the value of ia64_tpa(ia64_getreg(_IA64_REG_GP)
> is registered as gp value. When cpu comes into the above code, r1 is set
> to this value, I think. Therefore, r1 has physical address of __gp
> before DATA_PA_TO_VA(r1, temp1). How do you think?
>=20
> I think you are right, I also think r1 has to be set to __gp before
> calling ia64_init_handler.
>=20
  Yes, I agree GP should be set to __gp before calling into ia64_init_handl=
er, not only the region issue.
  E.g. If an OS_INIT happen in the context of a module, the GP value could =
be point to the modules GP.

  Thanks
  Zou Nan hai

> Regards,
> Takao Indoh
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
