From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 21:24:35 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603312123.k2VLNqg06655@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603311313530.8003@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Friday, March 31, 2006 1:15 PM
> > > They are not. They provide equivalent barrier when performed
> > > before/after a clear_bit, there is a big difference.
> >=20
> > Just to give another blunt brutal example, what is said here is equival=
ent
> > to say kernel requires:
> >=20
> >    <end of critical section>
> >    smp_mb_before_spin_unlock
> >    spin_unlock
> >=20
> > Because it is undesirable to have spin_unlock to leak into the critical
> > Section and allow critical section to leak after spin_unlock.  This is
> > just plain brain dead.
>=20
> I think we could say that lock semantics are different from barriers. The=
y=20
> are more like acquire and release on IA64. The problem with smb_mb_*** is=
=20
> that the coder *explicitly* requested a barrier operation and we do not=20
> give it to him.

I was browsing sparc64 code and it defines:

include/asm-sparc64/bitops.h:
#define smp_mb__after_clear_bit()      membar_storeload_storestore()

With my very na=EFve knowledge of sparc64, it doesn't look like a full barr=
ier.
Maybe sparc64 is broken too ...
