From: Jay Lan <jlan@sgi.com>
Date: Thu, 17 Aug 2006 18:53:19 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <44E4BB1F.5060004@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jack Steiner wrote:
> On Wed, Aug 16, 2006 at 03:34:52PM -0700, Jay Lan wrote:
> >=20
>=20
> Why did the crash occur? Was the disk full? Otherwise, the cached
> pages _should_ have been written to disk.
>=20
> Do you have a console log?
>=20

Hi Jack,

I reserved insufficient memory for the crash dump kernel.
Once i increased from 128M to 256M, the problem went away.

Thanks,
  - jay


oom-killer: gfp_mask=3D0x200d2, order=3D0

Call Trace:
  [<a0000001000138e0>] show_stack+0x40/0xa0
                                 sp=E000000015d57a40 bsp=E000000015d514a0
  [<a000000100013970>] dump_stack+0x30/0x60
                                 sp=E000000015d57c10 bsp=E000000015d51488
  [<a0000001000eb000>] out_of_memory+0x60/0x3a0
                                 sp=E000000015d57c10 bsp=E000000015d51448
  [<a0000001000eeb50>] __alloc_pages+0x3d0/0x520
                                 sp=E000000015d57c20 bsp=E000000015d513d0
  [<a0000001000e65d0>] generic_file_buffered_write+0x310/0xd00
                                 sp=E000000015d57c30 bsp=E000000015d512f0
  [<a0000001000e7620>] __generic_file_aio_write_nolock+0x660/0x740
                                 sp=E000000015d57cc0 bsp=E000000015d51280
  [<a0000001000e77f0>] generic_file_aio_write+0xf0/0x200
                                 sp=E000000015d57d30 bsp=E000000015d51220
  [<a0000001002343c0>] ext3_file_write+0x60/0x200
                                 sp=E000000015d57d40 bsp=E000000015d511e0
  [<a00000010012e470>] do_sync_write+0x170/0x1e0
                                 sp=E000000015d57d40 bsp=E000000015d511a0
  [<a00000010012fb30>] vfs_write+0x1b0/0x340
                                 sp=E000000015d57e20 bsp=E000000015d51150
  [<a0000001001307b0>] sys_write+0x70/0xe0
                                 sp=E000000015d57e20 bsp=E000000015d510d8
  [<a00000010000c180>] ia64_ret_from_syscall+0x0/0x20
                                 sp=E000000015d57e30 bsp=E000000015d510d8
  [<a000000000010620>] __kernel_syscall_via_break+0x0/0x20
                                 sp=E000000015d58000=20
bsp=E000000015d510d8
