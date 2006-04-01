From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 01 Apr 2006 02:16:51 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <442DE293.8020702@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603312123.k2VLNqg06655@unix-os.sc.intel.com> <Pine.LNX.4.64.0603311327050.8126@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603311327050.8126@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Christoph Lameter <clameter@sgi.com>
Cc: davem@davemloft.net, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> On Fri, 31 Mar 2006, Chen, Kenneth W wrote:
>=20
>=20
>>>I think we could say that lock semantics are different from barriers. Th=
ey=20
>>>are more like acquire and release on IA64. The problem with smb_mb_*** i=
s=20
>>>that the coder *explicitly* requested a barrier operation and we do not =

>>>give it to him.
>>
>>I was browsing sparc64 code and it defines:
>>
>>include/asm-sparc64/bitops.h:
>>#define smp_mb__after_clear_bit()      membar_storeload_storestore()
>>
>>With my very na=EFve knowledge of sparc64, it doesn't look like a full ba=
rrier.
>>Maybe sparc64 is broken too ...
>=20
>=20
> Dave, how does sparc64 handle this situation?

It looks like sparc64 always expects paired smp_mb__* operations,
before and after the clear_bit.

--=20
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com =

