From: Shaohua Li <shaohua.li@intel.com>
Date: Fri, 26 Dec 2008 02:42:02 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <20081226024202.GA13241@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Dec 25, 2008 at 12:01:11PM +0800, Shaohua Li wrote:
> On Thu, Dec 25, 2008 at 11:54:33AM +0800, Steven Rostedt wrote:
> >=20
> > On Thu, 2008-12-25 at 09:08 +0800, Shaohua Li wrote:
> > > On Thu, Dec 25, 2008 at 05:50:50AM +0800, Keith Owens wrote:
> > > > On Wed, 24 Dec 2008 08:29:05 -0500,=20
> > > > Steven Rostedt <srostedt@redhat.com> wrote:
> > > > >Yes I understand that the module and kernel code is set up differe=
ntly,
> > > > >PPC is pretty much the same in this aspect. I'm asking if it is ea=
sy to
> > > > >change a call from the module to kernel core to another function in
> > > > >kernel core?
> > > > >
> > > > >Question: if I have a call from the module to _mcount, how much ha=
s to
> > > > >change in the set up of the registers to make it call ftrace_call
> > > > >instead?  Perhaps we could link in a call to ftrace_call via the t=
ricks
> > > > >in recordmcount.pl to get the info needed to make that change?
> > > >=20
> > > > The IA64 kernel uses the same gp register throughout, it is compiled
> > > > with -mconstant-gp.  So changing the target address from one kernel
> > > > function to another only requires changing the destination address =
in
> > > > the PLT stub, no other registers are affected.
> > > yes, for kernel, this is simple. Just changing the target address is =
ok,
> > > and the change is atomic, as it's a 64-bit write. For module, it's not
> > > simple. Module has different gp register against kernel. In a module,
> > > _mcount must save its gp first and then jump to kernel. That's why we
> > > can't directly use a jump.
> > >=20
> > > I'm considering link some code to ftrace_call in recordmcount.pl, but
> > > recordmocunt.pl is called for each file. If a module has multiple fil=
es,
> > > there will be some duplicate code. Another issue how can we find the
> > > code's address when ftrace to convert code to nop.
> >=20
> > Since this still sounds like PPC actions, I'll try to show a pseudo code
> > style example.
> >=20
> > I'm assuming that a call to mcount from a module looks something like
> > this:
> >=20
> > 	save module gp
> > 	load kernel gp
> > 	jump to mcount (or to a mcount trampoline)
> >=20
> > Since mcount and ftrace_caller share the same gp, could we not just
> > change that jmp to ftrace_caller instead? (or to a trampoline to
> > ftrace_caller as we do in PPC).
> As the 25bit limit, we must use a mcount trampoline. In IA64, PLT stub
> will do:
> load kernel gp
> jump to mcount
> the PLT stub doesn't save gp, so it's not ok for the trampoline. This is
> what I said We need add another trampoline code to module. Loading
> module in IA64 only can add PLT stub, we need other approach for the
> trampoline code.
Tony:
The mcount call code is:
	alloc r40=3Dar.pfs,12,8,0
	mov r43=3Dr0;;
	mov r42=B0
	mov r41=3Dr1
	nop.i 0x0
	br.call.sptk.many b0 =3D _mcount;;

To convert it to nop, we can change it to:
	alloc r40=3Dar.pfs,12,8,0
	mov r43=3Dr0;;
	mov r42=B0
	mov r41=3Dr1
	nop.i 0x0
	nop.b 0x0

This code hasn't any impact to later instructions. Could we treat this
code as nop? It still executes some instructions. Not sure if this is
heavy.

Another light approach is, the code to be nop as:
	nop.m 0x0
	mov r3 =3D ip
	nop.b 0x0
	nop.m 0x0
	nop.i 0x0
	nop.i 0x0

We can change it back to:
	nop.m 0x0
	mov r3 =3D ip
	br.sptk.many trampoline
	nop.m 0x0
	nop.i 0x0
	nop.i 0x0

In the trampoline code, we then call _mcount. This approach still need
one extra instruction executed (second instruction) even for nop.
This should be lighter, but be more complex (add trampoline code to module)

Both the two methods should be ok for dyn ftrace, as we only change one
instrction one time and the instrcution is in one aligned long.

Thanks,
Shaohua
