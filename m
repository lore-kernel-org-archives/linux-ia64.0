From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 08 Jun 2004 08:03:20 +0000
Subject: Re: Who owns those locks ?
Message-Id: <40C572C8.20B13640@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <40A1F4BE.4A298352@nospam.org> <200406031139.58964.bjorn.helgaas@hp.com> <40C42E4B.15F1E605@nospam.org> <200406070906.54132.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Bjorn Helgaas wrote:
>=20
> There are a couple issues I was thinking of when
> I wrote "clean it up, pull the bits together...":
>=20
>         1) Tony Luck's question about what happens when
>            "shr.u r30 =3D r13, 12" yields zero in the 32-bit
>            lock value.  I'm not the 2.6 maintainer, but I'd
>            sure like to see some solution for this.  It would
>            be a nightmare to debug a system where one random
>            task didn't release locks correctly.  Since other
>            arches use a trick like this, I'm hoping they've
>            figured out something we can copy (I haven't looked).

Sure, I did not want to make an error like saying:
"640 K ought to be enough for everyone".

I'm afraid, there is no perfect solution.

- We do not want to change the lock size to 64 bits, do we ?
  -- Couple of new alignment problems.

- You keep my code, it is correct for a memory size up to 16 Tbytes.

- You shift by PAGE_SHIFT, rather than by 12 (using page size of
  16 Kbytes) =3D> up to  64 Tbytes.
  -- Not that much human readable lock values.

- You move to PAGE_SIZE =3D 64 K, you get human readable lock values
  up to 256 Tbytes.

- You could store the "PID | miraculous bit" (to avoid PID =3D 0
  problem).
  -- Somewhat longer code.

I expect the main stream IA64 kernel to move to PAGE_SIZE =3D 64 K by
the time there will be machines with more than 16 Tbytes of memory
(as the processors have got just a very limited number of
translation look aside buffer entries, and the ever growing
application / memory sizes result in higher TLB miss rate unless the
page size increases).


Regards,

Zolt=E1n
