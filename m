From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 29 May 2003 01:27:13 +0000
Subject: RE: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C32581.6ED347D8"
Message-Id: <marc-linux-ia64-105590723706062@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706053@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706053@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C32581.6ED347D8
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Thanks Keith for pointing out the issue with fs/proc/proc_misc.c for
!CONFIG_HUGETLB_PAGE.  Please use the attached small patch for
fs/proc/proc_misc.c (as is there in 2.5).



> -----Original Message-----
> From: Keith Owens [mailto:kaos@ocs.com.au]=20
> Sent: Wednesday, May 28, 2003 12:17 AM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb,=20
> unwind fixes
>=20
>=20
> 2.4.21-rc2-cset-1129 is 9 days old so some of these may have=20
> been fixed already.
>=20
> fs/proc/proc_misc.c:
>   Allow build with CONFIG_HUGETLB_PAGE=3Dn.
>=20
> arch/ia64/kernel/unwind.c:
>   Only call get_scratch_regs() when pt is really needed.  The=20
> premature
>   calls to get_scratch_regs() would pick up the wrong address=20
> for pt if
>   the register was in switch_stack and pt_regs had not been reached
>   yet, e.g. unw_access_ar(&info, UNW_AR_BSPSTORE,...) before pt_regs
>   had been reached.
>=20
>   Correct debugging code that had the wrong the number of parameters
>   and referred to non-existent variables.  Only shows up with
>     CFLAGS_unwind.o +=3D -DUNW_DEBUG=3D<number>.
>=20
>=20
> Index: 21-rc2.3/fs/proc/proc_misc.c
> --- 21-rc2.3/fs/proc/proc_misc.c Wed, 28 May 2003 16:39:56=20
> +1000 kaos (linux-2.4/o/b/48_proc_misc. 1.1.1.1.1.1.1.17 644)
> +++ 21-rc2.3(w)/fs/proc/proc_misc.c Wed, 28 May 2003 16:57:30=20
> +1000 kaos=20
> +++ (linux-2.4/o/b/48_proc_misc. 1.1.1.1.1.1.1.17 644)
> @@ -208,7 +208,9 @@ static int meminfo_read_proc(char *page,
>  		K(i.totalswap),
>  		K(i.freeswap));
> =20
> +#ifdef CONFIG_HUGETLB_PAGE
>  	len +=3D hugetlb_report_meminfo(page + len);
> +#endif
> =20
>  	return proc_calc_metrics(page, start, off, count, eof,=20
> len);  #undef B
> Index: 21-rc2.3/arch/ia64/kernel/unwind.c
> --- 21-rc2.3/arch/ia64/kernel/unwind.c Sun, 18 May 2003=20
> 15:06:40 +1000 kaos (linux-2.4/r/c/42_unwind.c=20
> 1.1.2.1.1.2.3.1.1.1.1.4 644)
> +++ 21-rc2.3(w)/arch/ia64/kernel/unwind.c Wed, 28 May 2003 17:05:42=20
> +++ +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.4 644)
> @@ -371,12 +371,11 @@ unw_access_br (struct unw_frame_info *in
>  	unsigned long *addr;
>  	struct pt_regs *pt;
> =20
> -	pt =3D get_scratch_regs(info);
>  	switch (regnum) {
>  		/* scratch: */
> -	      case 0: addr =3D &pt->b0; break;
> -	      case 6: addr =3D &pt->b6; break;
> -	      case 7: addr =3D &pt->b7; break;
> +	      case 0: pt =3D get_scratch_regs(info); addr =3D=20
> &pt->b0; break;
> +	      case 6: pt =3D get_scratch_regs(info); addr =3D=20
> &pt->b6; break;
> +	      case 7: pt =3D get_scratch_regs(info); addr =3D=20
> &pt->b7; break;
> =20
>  		/* preserved: */
>  	      case 1: case 2: case 3: case 4: case 5:
> @@ -409,15 +408,15 @@ unw_access_fr (struct unw_frame_info *in
>  		return -1;
>  	}
> =20
> -	pt =3D get_scratch_regs(info);
> -
>  	if (regnum <=3D 5) {
>  		addr =3D *(&info->f2_loc + (regnum - 2));
>  		if (!addr)
>  			addr =3D &info->sw->f2 + (regnum - 2);
>  	} else if (regnum <=3D 15) {
> -		if (regnum <=3D 9)
> +		if (regnum <=3D 9) {
> +			pt =3D get_scratch_regs(info);
>  			addr =3D &pt->f6  + (regnum - 6);
> +		}
>  		else
>  			addr =3D &info->sw->f10 + (regnum - 10);
>  	} else if (regnum <=3D 31) {
> @@ -447,7 +446,6 @@ unw_access_ar (struct unw_frame_info *in
>  	unsigned long *addr;
>  	struct pt_regs *pt;
> =20
> -	pt =3D get_scratch_regs(info);
>  	switch (regnum) {
>  	      case UNW_AR_BSP:
>  		addr =3D info->bsp_loc;
> @@ -502,10 +500,12 @@ unw_access_ar (struct unw_frame_info *in
>  		break;
> =20
>  	      case UNW_AR_RSC:
> +		pt =3D get_scratch_regs(info);
>  		addr =3D &pt->ar_rsc;
>  		break;
> =20
>  	      case UNW_AR_CCV:
> +		pt =3D get_scratch_regs(info);
>  		addr =3D &pt->ar_ccv;
>  		break;
> =20
> @@ -1931,7 +1931,7 @@ init_frame_info (struct unw_frame_info *
>  		   "  pr     0x%lx\n"
>  		   "  sw     0x%lx\n"
>  		   "  sp     0x%lx\n",
> -		   __FUNCTION__, (unsigned long) task,=20
> rbslimit, rbstop, stktop, stklimit,
> +		   __FUNCTION__, (unsigned long) t, rbslimit,=20
> rbstop, stktop,=20
> +stklimit,
>  		   info->pr, (unsigned long) info->sw, info->sp);
>  	STAT(unw.stat.api.init_time +=3D ia64_get_itc() - start;=20
> local_irq_restore(flags));  } @@ -1952,7 +1952,7 @@=20
> unw_init_from_interruption (struct unw_f
>  		   "  bsp    0x%lx\n"
>  		   "  sof    0x%lx\n"
>  		   "  ip     0x%lx\n",
> -		   info->bsp, sof, info->ip);
> +		   __FUNCTION__, info->bsp, sof, info->ip);
>  	find_save_locs(info);
>  }
> =20
> @@ -1970,7 +1970,7 @@ unw_init_frame_info (struct unw_frame_in
>  		   "  bsp    0x%lx\n"
>  		   "  sol    0x%lx\n"
>  		   "  ip     0x%lx\n",
> -		   info->bsp, sol, info->ip);
> +		   __FUNCTION__, info->bsp, sol, info->ip);
>  	find_save_locs(info);
>  }
> =20
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org=20
> http://lists.linuxia64.org/lists/listinfo/linu> x-ia64
>=20

------_=_NextPart_001_01C32581.6ED347D8
Content-Type: application/octet-stream;
	name="hugetlb_report_meminfo-2420.diff"
Content-Transfer-Encoding: base64
Content-Description: hugetlb_report_meminfo-2420.diff
Content-Disposition: attachment;
	filename="hugetlb_report_meminfo-2420.diff"

ZGlmZiAtTnVyIEEvZnMvcHJvYy9wcm9jX21pc2MuYyBCL2ZzL3Byb2MvcHJvY19taXNjLmMNCi0t
LSBBL2ZzL3Byb2MvcHJvY19taXNjLmMJTW9uIE1hciAxNyAyMzo0MDoxMCAyMDAzDQorKysgQi9m
cy9wcm9jL3Byb2NfbWlzYy5jCU1vbiBNYXIgMTcgMjM6NDI6MjQgMjAwMw0KQEAgLTM2LDYgKzM2
LDcgQEANCiAjaW5jbHVkZSA8bGludXgvaW5pdC5oPg0KICNpbmNsdWRlIDxsaW51eC9zbXBfbG9j
ay5oPg0KICNpbmNsdWRlIDxsaW51eC9zZXFfZmlsZS5oPg0KKyNpbmNsdWRlIDxsaW51eC9odWdl
dGxiLmg+DQogDQogI2luY2x1ZGUgPGFzbS91YWNjZXNzLmg+DQogI2luY2x1ZGUgPGFzbS9wZ3Rh
YmxlLmg+DQo=

------_=_NextPart_001_01C32581.6ED347D8--

