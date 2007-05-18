From: Robin Holt <holt@sgi.com>
Date: Fri, 18 May 2007 18:35:20 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <20070518183520.GA9217@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, May 17, 2007 at 10:02:45PM -0500, Robin Holt wrote:
> On Thu, May 17, 2007 at 08:16:55AM -0600, David Mosberger-Tang wrote:
> > On 5/17/07, Keith Owens <kaos@sgi.com> wrote:
> >=20
> > >David Mosberger
> > >reckons that unwind should never cause an error, maybe we should be
> > >looking at adding more checks to the unwind code to cope with spurious
> > >addresses?
> >=20
> > That's correct.  If the unwinder causes MCAs, it's broken.  Robin, can
> > you look into why the memory-access safety-checks in the unwinder
> > aren't sufficient to avoid the MCAs you're seeing?
>=20
> I don't think it got very far at all.
>=20
> The task in question is calling get_wchan on itself.  It is at
> >> px *(task_struct *)0xe003819a00000000 | grep ksp
>                 ksp =3D 0xe003819a00007900
> >> px 0xe003819a00007900 + 16
> 0xe003819a00007910
> >> px *(switch_stack *)0xe003819a00007910 | grep bsp
>         ar_bspstore =3D 0xe003819a00000000
>=20
>=20
> Here we start to run into difficulties.  ar_bspstore is the same address
> as our task_struct.  info->regstk.top =3D 0xe003819a00000000 which leads
> to unw_init_frame_info calculating info->bsp =3D 0xe0038199ffffff30
> which is near the addresses causing problems (0xe0038199ffffff80 and
> 0xe0038199ffffffe0).  Notice it is in the page before our task_struct.

I think I have everything figured out now.  Address range for our tasks
switch stack is 0xe001849a00007910 to 0xe001849a00007b20.

Or unw_frame_info structure allocated by get_wchan() on the memory stack
happens to reside at 0xe001849a00007b20 to 0xe001849a00007ce8.

Assume we are in get_wchan and r12 =3D 0xe001849a00007b20.  We take
an interrupt.  The switch stack gets allocated on the memory stack in
the address ranges above.  Upon return from the interrupt, we proceed
to call unw_init_from_blocked_task() which called unw_init_frame_info().

unw_init_frame_info does:
0xa000000100041aa0 <unw_init_frame_info>:         [MMI]       alloc r36=3Da=
r.pfs,9,6,0
0xa000000100041aa6 <unw_init_frame_info+0x6>:                 adds r12=3D-1=
6,r12
0xa000000100041aac <unw_init_frame_info+0xc>:                 mov r35=B0
0xa000000100041ab0 <unw_init_frame_info+0x10>:    [MII]       nop.m 0x0
0xa000000100041ab6 <unw_init_frame_info+0x16>:                mov r38=3Dr32=
;;
0xa000000100041abc <unw_init_frame_info+0x1c>:                adds r9=16,r12
0xa000000100041ac0 <unw_init_frame_info+0x20>:    [MMI]       mov r39=3Dr0
0xa000000100041ac6 <unw_init_frame_info+0x26>:                nop.m 0x0
0xa000000100041acc <unw_init_frame_info+0x2c>:                mov r40E6;;
0xa000000100041ad0 <unw_init_frame_info+0x30>:    [MIB]       st8 [r9]=3Dr33

which ends up placing r33 (struct task_struct *) onto the stack at
exactly the location of the no longer valid switch_stack struct pointed
to by this threads ->ksp.

This comes down to we need to take an interrupt in get_wchan when called
on our own task between the time when r12 is updated to allocate the
unw_frame_info structure and when unw_init_from_blocked_task() is called.

Seeing how that is only a few instructions, I would expect this to be
a fairly small window of opportunity.

I am going to submit two patches.  One which improves the error checking
in the unwind functions.  The other is essentially the patch I produced
yesterday.

Thanks,
Robin
