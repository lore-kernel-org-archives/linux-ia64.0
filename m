From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 02 Jun 2006 08:54:34 +0000
Subject: RE: [Fastboot] Where is the latest patch of kdump for ia64?
Message-Id: <08B1877B2880CE42811294894F33AD5C053B31@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060602143200oomichi@mail.jp.nec.com>
In-Reply-To: <20060602143200oomichi@mail.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Ken'ichi Ohmichi
> Sent: 2006=C4=EA6=D4=C22=C8=D5 13:32
> To: Takao Indoh
> Cc: khalid_aziz@hp.com; linux-ia64@vger.kernel.org; fastboot@lists.osdl.o=
rg
> Subject: Re: [Fastboot] Where is the latest patch of kdump for ia64?
>=20
> Hi.
>=20
> 2006/05/31 18:40:54 +0900, Takao Indoh <indou.takao@soft.fujitsu.com> wro=
te:
> >I am interested in kdump on ia64 and I am looking for the latest
> >patch of kdump.
> I found ia64-kdump patch from Zou Nan hai. Isn't this patch latest?
> http://lists.osdl.org/pipermail/fastboot/2006-March/002577.html
>=20
> I tested this patch on the system. As the result, the system froze while
> switching to second kernel (in relocate_new_kernel).
> Can you do kdump with this patch?
>=20
> Test environment:
>   CPU        : Itanium 2, 1.0GHz
>   Memory     : 6GB
>   Kernel     : linux-2.6.15
>                 + ia64-kexec-kdump-2.6.15.patch (2006/03/14 from Zou Nan =
hai)
>   Kexec-tools: kexec-tools-1.101
>                 + kexec-tools-1.101-kdump.patch (2006/03/14 from Zou Nan =
hai)
>                 + ia64-kexec-tool-kdump.patch   (2006/03/14 from Zou Nan
> hai)
>   Package    : RHEL4AS-U3
>=20
> Thanks
> Ken'ichi Ohmichi
I will send out an updated ia64 kdump soon.
Hopefully I will send it in next week.

Thanks
Zou nan hai

> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
