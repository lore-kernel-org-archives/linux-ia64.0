From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 12 Oct 2006 01:04:56 +0000
Subject: RE: [PATCH] kexec-tools: ia64: icache flush should align to 32-bytes
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086AE8@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <452D72F3.50107@hp.com>
In-Reply-To: <452D72F3.50107@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Terry Loftin [mailto:terry.loftin@hp.com]
> Sent: 2006=C4=EA10=D4=C212=C8=D5 6:41
> To: linux-ia64@vger.kernel.org; fastboot@lists.osdl.org
> Cc: Zou, Nanhai; horms@verge.net.au
> Subject: [PATCH] kexec-tools: ia64: icache flush should align to 32-bytes
>=20
> Hi,
> I've run into problems testing kexec/kdump on a Montecito revision C
> processor.  In purgatory, __dummy_efi_function is copied onto the
> end of the command line boot parameter (command_line + command_line_len)
> and this address is used to replace the EFI call to set_virtual_address_m=
ap().
> The copied range is then icache flushed.
>=20
> The destination address is aligned to 16-bytes (in kexec-elf-ia64.c), but
> the fc.i instruction flushes a 32-byte range "associated" with that addre=
ss.
> When my command line length is 16-byte aligned but not 32-byte aligned, t=
his
> results in the first 16-bytes of __dummy_efi_function getting flushed (and
> the 16 bytes prior to that), but the second half of the function (the part
> with the br.ret) does not get flushed.  kdump then hangs in purgatory.  By
> adding a few spaces to my command line, it becomes both 16 and 32-byte
> aligned, and kdump works.
>=20
>=20
> This patch makes icache_flush_range() align the start address to 32-bytes=
 and
> account for the difference.  The patch is against Horms kexec-tools-testi=
ng
> tree.  As a side note, you could also fix this by just adding 32 to the l=
ength
> passed to flush_icache_range() but that hides the dependent behavior.
>=20
> Thanks,
> -T

It seems I was always testing with command line more than 16 bytes length..=
...

Thanks.
Acked-by: Zou Nan hai <nanhai.zou@intel.com>
