From: Steven Rostedt <srostedt@redhat.com>
Date: Wed, 24 Dec 2008 13:29:05 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1230125345.30177.128.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


On Wed, 2008-12-24 at 16:08 +0800, Shaohua Li wrote:
> On Wed, Dec 24, 2008 at 09:00:24AM +0800, Steven Rostedt wrote:
> >=20
> > On Wed, 2008-12-24 at 08:54 +0800, Shaohua Li wrote:
> >=20
> > >=20
> > > > > +static unsigned char *ftrace_nop_replace(void)
> > > > > +{
> > > > > +     return ftrace_nop_code;
> > > > > +}
> > > > > +
> > > > > +/* In IA64, each function will be added below two bundles with -=
pg option */
> > > > > +static unsigned char __attribute__((aligned(8)))
> > > > > +ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
> > > > > +     0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,1=
2,8,0 */
> > > > > +     0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
> > > > > +     0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
> > > > > +     0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
> > > > > +     0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */
> > > >=20
> > > > If you made your own PLT stub, could you just change the one line to
> > > > jump to that stub?
> > > A simple jump to PLT stub doesn't work in IA64, as a lot of registers
> > > should be saved. I'll do more investigation.
> >=20
> > So the registers are different depending on what function is called?
> > That is, you would have to change more than one of these lines if you
> > were to change it from calling _mcount to calling ftrace_stub?
> Yes, module has different gp register against kernel. Before jump to
> kernel, the register must be saved.
> We need insert trampoline code in each module. The code should do the
> register save and jump to ftrace_caller. Add a weak function in module.h
> seems ok for the trampoline code, but I don't know how to find the
> function address.

Yes I understand that the module and kernel code is set up differently,
PPC is pretty much the same in this aspect. I'm asking if it is easy to
change a call from the module to kernel core to another function in
kernel core?  I must apologize that I'm pretty ignorant to how ia64
works. So there very well can be something that I do not understand that
will prevent this.

Question: if I have a call from the module to _mcount, how much has to
change in the set up of the registers to make it call ftrace_call
instead?  Perhaps we could link in a call to ftrace_call via the tricks
in recordmcount.pl to get the info needed to make that change?

-- Steve


