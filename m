From: Andreas Schwab <schwab@suse.de>
Date: Fri, 06 Feb 2004 11:46:34 +0000
Subject: Re: gcc problems
Message-Id: <jeisiksa5h.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040206000058.7e928d80.akpm@osdl.org>
In-Reply-To: <20040206000058.7e928d80.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jim Wilson <wilson@specifixinc.com> writes:

> On Fri, 2004-02-06 at 00:00, Andrew Morton wrote:
>> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c: In function `uw_frame_s=
tate_for':
>> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure h=
as no member named `sc_rbs_base'
>> ../../gcc-3.4-cvs/gcc/config/ia64/unwind-ia64.c:1779: error: structure h=
as no member named `sc_loadrs'
>
> This is from the MD_FALLBACK_FRAME_STATE_FOR macro in
> gcc/config/ia64/linux.h, which handles machine and OS dependent
> unwinding from signal handers.  It uses signal.h and sys/context.h.=20
> These are things that could have perhaps changed with a new kernel or
> glibc.  If the signal context structure has changed, then we need a new
> version of this code, and will somehow have to choose the right one.

The fields were named differently in old versions of glibc, but the whole
layout didn't change in any way.

-  unsigned long int sc_rsvd[16];/* reserved for future use */
+  unsigned long int sc_rbs_base;/* NULL or new base of sighandler's rbs */
+  unsigned long int sc_loadrs;	/* see description above */
+  unsigned long int sc_ar25;	/* cmp8xchg16 uses this */
+  unsigned long int sc_ar26;	/* rsvd for scratch use */
+  unsigned long int sc_rsvd[12];/* reserved for future use */

> The easiest workaround is probably to install libunwind on your system

The right fix is not to use a 2 years old glibc.

revision 1.7
date: 2001/10/01 00:04:10;  author: drepper;  state: Exp;  lines: +3 -1
(struct sigcontext): Add sc_loadrs and sc_rbs_bas to match current kernel.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
