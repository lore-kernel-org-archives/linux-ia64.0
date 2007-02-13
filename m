From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 13 Feb 2007 01:08:06 +0000
Subject: RE: [Fastboot] Zero size /proc/vmcore on ia64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BEA@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070212185756.GA22524@strauss.suse.de>
In-Reply-To: <20070212185756.GA22524@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Bernhard Walle
> Sent: 2007=C4=EA2=D4=C213=C8=D5 5:50
> To: fastboot@lists.osdl.org; Linux-IA64
> Subject: Re: [Fastboot] Zero size /proc/vmcore on ia64
>=20
> * Bernhard Walle <bwalle@suse.de> [2007-02-12 19:57]:
> > * Zou, Nanhai <nanhai.zou@intel.com> [2007-02-09 00:45]:
> > >  I have not implement serial print in purgatory code yet, see
> > >  comments in purgatory/arch/ia64/console-ia64.c However from your
> > >  print, I can see last 2 entries of efi mem map are corrupt.
> >
> > I have the same problem (corrupted memory map entries), and the cause
> > was in kexec-tools, patch below. I'm not sure if the fix is right, at
> > least the problem is the uninitialised value of size. :)
>=20
> But that patch doesn't fix the zero-size problem, it just fixes the
> invalid EFI map problem. That patch (against kexec-tools, not against
> the kernel) fixes both.
>=20
> The problem is simply that the space for the core header doesn't
> occupy a EFI page.
>=20
> Signed-off-by: Bernhard Walle <bwalle@suse.de>
>=20
> ---
>  crashdump-ia64.c |   14 ++++++++++----
>  kexec-ia64.h     |    6 +++++-
>  2 files changed, 15 insertions(+), 5 deletions(-)
>=20
> diff --git a/kexec/arch/ia64/crashdump-ia64.c
> b/kexec/arch/ia64/crashdump-ia64.c
> index 14e95a6..e3d8b41 100644
> --- a/kexec/arch/ia64/crashdump-ia64.c
> +++ b/kexec/arch/ia64/crashdump-ia64.c
> @@ -220,8 +220,8 @@ int load_crashdump_segments(struct kexec_info *info,
> struct mem_ehdr *ehdr,
>  {
>  	struct memory_range *mem_range;
>  	int nr_ranges;
> -	unsigned long sz;
> -	size_t size;
> +	unsigned long sz, memsz;
> +	size_t size =3D 0;
>  	void *tmp;
>  	if (info->kexec_flags & KEXEC_ON_CRASH ) {
>  		if (get_crash_memory_ranges(&mem_range, &nr_ranges) =3D 0) {
> @@ -235,10 +235,16 @@ int load_crashdump_segments(struct kexec_info *info,
> struct mem_ehdr *ehdr,
>  						       &tmp, &sz) < 0)
>  				return -1;
>=20
> -			elfcorehdr =3D add_buffer(info, tmp, sz, sz, EFI_PAGE_SIZE,
> min_base,
> +			/* round sz up */
> +			if (sz !=3D ((sz >> EFI_PAGE_SHIFT) << EFI_PAGE_SHIFT))
> +				memsz =3D ((sz >> EFI_PAGE_SHIFT) + 1) << EFI_PAGE_SHIFT;
> +			else
> +				memsz =3D sz;
> +
> +			elfcorehdr =3D add_buffer(info, tmp, sz, memsz, EFI_PAGE_SIZE,
> min_base,
>  					max_addr, -1);


  The kexec-tools version seems to be different.
  In my local version the size is aligned, there is size =3D (size + EFI_PA=
GE_SIZE - 1) & ~(EFI_PAGE_SIZE -1); so that is why I did not see this issue=
, someone has changed the code...
  Anyway you can round size to page size like this instead of if else, this=
 will save 3 lines of code .:)

  Thanks
  Zou Nan hai=20

>  			loaded_segments[loaded_segments_num].start =3D elfcorehdr;
> -			loaded_segments[loaded_segments_num].end =3D elfcorehdr + size;
> +			loaded_segments[loaded_segments_num].end =3D elfcorehdr + memsz;
>  			loaded_segments[loaded_segments_num].reserved =3D 1;
>  			loaded_segments_num++;
>  			cmdline_add_elfcorehdr(cmdline, elfcorehdr);
> diff --git a/kexec/arch/ia64/kexec-ia64.h b/kexec/arch/ia64/kexec-ia64.h
> index 176d5f9..28a728b 100644
> --- a/kexec/arch/ia64/kexec-ia64.h
> +++ b/kexec/arch/ia64/kexec-ia64.h
> @@ -10,6 +10,10 @@ int update_loaded_segments(struct kexec_info *info, st=
ruct
> mem_ehdr *ehdr);
>  void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
>  			  unsigned long addr);
>=20
> -#define EFI_PAGE_SIZE	  (1UL<<12)
> +#define EFI_PAGE_SHIFT		12
> +
> +#define EFI_PAGE_SIZE	  (1UL<<EFI_PAGE_SHIFT)
>  #define ELF_PAGE_SIZE	  (1UL<<16)
> +
> +
>  #endif /* KEXEC_IA64_H */
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
