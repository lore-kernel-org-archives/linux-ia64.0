From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 14 Dec 2006 09:24:23 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <45811847.1000504@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:
> On Wed, Dec 13, 2006 at 11:02:48AM +0100, Zoltan Menyhart wrote:
>=20
>>I like this code with the following slight modifications:
>>- let's keep "m" as pointer to volatile
>=20
> Why?  What benefit is there to doing an ld4.acq instead of a plain ld4?

It is not about the ld4.acq, but the volatile storage class (=3D don't
assume it wont be changed by someone else, do reload it each time).

Not using the volatile key word allows the compiler to optimize
out the actual load in loops like:

	while (test_and_set_bit(bitnum, addr))
		;


>>- let's keep on using "__u32" types
>=20
> Why be so ugly?

- It has been like that for a while, I got used to it :-)
- grep-ing for "__u32" gives less false positives that grep-ing for "u32"
=20
>>- return the old bit
>=20
> I don't understand what you mean here.

In your code:
...
    while (!(old & bit)) {
...
            return 1;
...
    }
    return 0;

You return the inverse of the old bit, while the orig. code says:

" * test_and_set_bit - Set a bit and return its old value"

Thanks.

Zolt=E1n Menyh=E1rt

