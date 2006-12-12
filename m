From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 12 Dec 2006 15:01:00 +0000
Subject: test_and_set_bit implementation
Message-Id: <457EC42C.90002@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

We have got a test_and_set_bit implementation as follows:

static __inline__ int
test_and_set_bit (int nr, volatile void *addr)
{
        __u32 bit, old, new;
        volatile __u32 *m;

        m =3D (volatile __u32 *) addr + (nr >> 5);
        bit =3D 1 << (nr & 31);
        do {
                old =3D *m;
                new =3D old | bit;
        } while (cmpxchg_acq(m, old, new) !=3D old);
        return (old & bit) !=3D 0;
}

Let's assume the bit test & set is already set, why is then the
cmpxchg_acq() executed? Cannot we just return, e.g. like this?

        do {
                old =3D *m;
		if (old & bit)
			return 1;
                new =3D old | bit;
        } while (cmpxchg_acq(m, old, new) !=3D old);

Thanks,

Zolt=E1n Menyh=E1rt
