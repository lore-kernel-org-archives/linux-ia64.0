From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Wed, 13 Dec 2006 10:20:00 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <457FD3D0.2010609@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

> I think this will work. However, usually you execute bit test and test=20
> because the bit is not set and you want to set it. This change would=20
> optimize a rarely taken path. Probably not worth it.

How much is the probability that the bit is not set?

Adding a test can cost only a few cycles, say max 4.

For an atomic operation, you need to go out and snoop.

Let's have a look at e.g. the "bit_spin_lock()":

static inline void bit_spin_lock(int bitnum, unsigned long *addr)
{
        preempt_disable();
        while (test_and_set_bit(bitnum, addr)) {
                while (test_bit(bitnum, addr)) {
                        preempt_enable();
                        cpu_relax();
                        preempt_disable();
                }
        }
        __acquire(bitlock);
}

By executing the atomic operation unconditionally, you kill
the cache line all the other waiting processors looping at.

Thanks,

Zolt=E1n Menyh=E1rt
