From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 07 Sep 2006 00:57:13 +0000
Subject: RE: [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <08B1877B2880CE42811294894F33AD5C053BF5@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
In-Reply-To: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Takao Indoh
> Sent: 2006=C4=EA9=D4=C26=C8=D5 17:23
> To: Keith Owens
> Cc: fastboot@lists.osdl.org; linux-ia64@vger.kernel.org
> Subject: Re: [PATCH]IA64 kexec/kdump patch for INIT
>=20
> On Wed, 06 Sep 2006 18:06:53 +0900, Takao Indoh wrote:
>=20
> >>>+		/* change region of gp to region5 */
> >>>+		asm volatile ("movl gp=3D__gp"::: "memory");
> >>
> >>Why?  gp is already pointing at the kernel code before we enter
> >>ia64_init_handler().
> >
> >The purpose of this code is just changing region of gp from region7 to
> >region5. For example, if gp is e000000004ace170, I want to change gp to
>                                 ~~~~~~~~~~~~~~~~e000000000ace170
> Sorry, I mistook address...
>=20
>=20
> Regards,
> Takao Indoh
>=20
  You don't need to set gp here. Control page does not use GP, and purgator=
y code will set GP to a physical address which was pre-calculated at the ti=
me of crash kernel loading.
  Thanks
  Zou Nan hai
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
