From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 21:28:13 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603311327050.8126@schroedinger.engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-1700579579-988016669-1143840493=:8126"
List-Id: <linux-ia64.vger.kernel.org>
References: <200603312123.k2VLNqg06655@unix-os.sc.intel.com>
In-Reply-To: <200603312123.k2VLNqg06655@unix-os.sc.intel.com>
To: davem@davemloft.net
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1700579579-988016669-1143840493=:8126
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 31 Mar 2006, Chen, Kenneth W wrote:

> > I think we could say that lock semantics are different from barriers. T=
hey=20
> > are more like acquire and release on IA64. The problem with smb_mb_*** =
is=20
> > that the coder *explicitly* requested a barrier operation and we do not=
=20
> > give it to him.
>=20
> I was browsing sparc64 code and it defines:
>=20
> include/asm-sparc64/bitops.h:
> #define smp_mb__after_clear_bit()      membar_storeload_storestore()
>=20
> With my very na=EFve knowledge of sparc64, it doesn't look like a full ba=
rrier.
> Maybe sparc64 is broken too ...

Dave, how does sparc64 handle this situation?

---1700579579-988016669-1143840493=:8126--
