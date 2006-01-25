From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 23:56:54 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601252356.k0PNutg01667@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Wednesday, January 25, 2006 3:10 PM
> On Wed, 25 Jan 2006, Brent Casavant wrote:
>=20
> > Hmm.  I have only scant evidence to go on from the panic output,
> > but it looks like "current" (r13) is not equal to the value of "next"
> > by the time we get into sn_migrate().  One example run apparently
> > has current=E0000030079d8000, next=E000003015990000.
>=20
> Got it!  We're context switching.  "next" became "current".  No
> telling what on earth "next's next" was.  So after calling
> ia64_switch_to(next), I have to refer to "current" in order to
> access what was "next" before the call.  My brain's all knotted up.

Oh my gosh, what a nasty bug !!  Thanks for finding it. "next's next"
in the "next" context is the task that "next" was previously context
switched to.  Enough mind-boggling wording :-(

p1 switch to p2, then switch to p3 and p3 switched to p1, after
ia64_switch_to, p1 next is pointing to p2.  The kernel would die and
fall flat on its face in no time.  I guess I'm overly lucky by not
deriving anything pointer value read from thread_info->cpu/last_cpu.

- Ken

