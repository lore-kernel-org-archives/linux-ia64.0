From: Andrew Morton <akpm@osdl.org>
Date: Mon, 20 Sep 2004 18:35:27 +0000
Subject: Re: Unaligned kernel access in crypto/sha1.c
Message-Id: <20040920113527.76b23801.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040916231638.GA32514@lucon.org>
	<20040917221108.32545506.akpm@osdl.org>
	<20040920181645.GA32526@lucon.org>
In-Reply-To: <20040920181645.GA32526@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "H. J. Lu" <hjl@lucon.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"H. J. Lu" <hjl@lucon.org> wrote:
>
> On Fri, Sep 17, 2004 at 10:11:08PM -0700, Andrew Morton wrote:
> > "H. J. Lu" <hjl@lucon.org> wrote:
> > >
> > > I got
> > >=20
> > > Sep 16 15:45:32 gnu-2 kernel: kernel unaligned access to
> > > 0xa0000002001c008e, ip=3D0xa0000001002135e0
> > > Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> > > 0xa0000002002d005e, ip=3D0xa0000001002135e0
> > > Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> > > 0xa0000002002d006e, ip=3D0xa0000001002135e0
> > > Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> > > 0xa0000002002d007e, ip=3D0xa0000001002135e0
> > > Sep 16 15:45:37 gnu-2 kernel: kernel unaligned access to
> > > 0xa0000002002d008e, ip=3D0xa0000001002135e0
> > >=20
> > > on ia64 from sha1_transform in crypto/sha1.c:
> > >=20
> > > /* Hash a single 512-bit block. This is the core of the algorithm. */
> > > static void sha1_transform(u32 *state, const u8 *in)
> > > {
> > >         u32 a, b, c, d, e;
> > >         u32 block32[16];
> > >                                                                      =
          =20
> > >         /* convert/copy data to workspace */
> > >         for (a =3D 0; a < sizeof(block32)/sizeof(u32); a++)
> > >           block32[a] =3D be32_to_cpu (((const u32 *)in)[a]);
> > > 				     ^^^^^^^^^^^^^^^^
> > > 				 This may not be aligned for u32 on ia64.
> > >=20
> > >=20
> >=20
> > We really need to know the call trace here.
> >=20
>=20
> This is from a kernel with signed module support.
>=20
> kernel unaligned access to 0xa0000002002e47ee, ip=3D0xa000000100211960
> =20
> Call Trace:
>  [<a000000100017490>] show_stack+0x90/0xc0
>                                 sp=E00000017b8cf610
> bsp=E00000017b8c9330
>  [<a0000001000174f0>] dump_stack+0x30/0x60
>                                 sp=E00000017b8cf7e0
> bsp=E00000017b8c9318
>  [<a000000100043100>] ia64_handle_unaligned+0x540/0x2600
>                                 sp=E00000017b8cf7e0
> bsp=E00000017b8c9290
>  [<a0000001000101b0>] ia64_prepare_handle_unaligned+0x30/0x60
>                                 sp=E00000017b8cf990
> bsp=E00000017b8c9290
>  [<a00000010000fbe0>] ia64_leave_kernel+0x0/0x260
>                                 sp=E00000017b8cfba0
> bsp=E00000017b8c9290
>  [<a000000100211960>] sha1_transform+0x60/0x3160
>                                 sp=E00000017b8cfd70
> bsp=E00000017b8c9128
>  [<a000000100214c60>] sha1_update+0x120/0x1a0
>                                 sp=E00000017b8cfda0
> bsp=E00000017b8c90e0
>  [<a00000010020fd40>] update_kernel+0x60/0x100
>                                 sp=E00000017b8cfda0
> bsp=E00000017b8c90b0
>  [<a0000001000b3340>] module_verify_sig+0x660/0x740
>                                 sp=E00000017b8cfda0

The bug is in either module_verify_sig() or in update_kernel().

Neither of these functions are present in kernel.org kernels, so there's
some sort of lesson there.
