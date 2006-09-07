From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Sep 2006 16:38:47 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <20060907163847.GA5794@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Sep 07, 2006 at 11:08:34AM +0200, Andreas Schwab wrote:
> Takao Indoh <indou.takao@jp.fujitsu.com> writes:
>=20
> > The disassemble code:
> > a000000100047080:       0b 38 01 02 00 24       [MMI]       addl r39=3D=
0,r1;;
> > a000000100047086:       50 02 9c 00 42 00                   mov r37=3Dr=
39
> > a00000010004708c:       00 00 04 00                         nop.i 0x0;;
> > a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr3=
7;;
> > a000000100047096:       c0 02 80 00 42 00                   mov r44=3Dr=
32
> > a00000010004709c:       00 00 04 00                         nop.i 0x0
> > a0000001000470a0:       17 00 02 51 02 14       [BBB]       br.call.spt=
k.many b0=A0000001000db4a0 <crash_kexec>
> >
> > This disassembled code does not change content of r1.
>=20
> It does:
>=20
> a000000100047090:       0a 08 00 4a 00 21       [MMI]       mov r1=3Dr37;;

But looking before that instruction r37 is a copy of r39 (mov r37=3Dr39).
r39 was calculated by "addl r39=3D0,r1" i.e. r1+0, also known as "r1". So
this sequence just takes the original value from r1 and puts it into r1
(passing through two other registers along the way).  Not only unhelpful,
but inefficient too :-)

Perhaps just make a tiny function:

GLOBAL_ENTRY(ia64_set_gp)
	movl r1=3D__gp
	br.ret.sptk.many b0
END(ia64_set_gp)

and put it in head.S to bypass this "cleverness" by gcc and
also avoid the need for inline asm.

-Tony

---
Yarn store opening in Sunnyvale, CA on Oct 14th. http://purlescenceyarns.com
