From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 14 Dec 2006 09:37:56 +0000
Subject: Re: test_and_set_bit implementation
Message-Id: <45811B74.2020405@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <457EC42C.90002@bull.net>
In-Reply-To: <457EC42C.90002@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:

>>How much is the probability that the bit is not set?

> Depends on the load on the system. Typically very much near 100%

If you are right, why do we need "bit_spin_lock()" that much complicated?

       while (test_and_set_bit(bitnum, addr)) {
               while (test_bit(bitnum, addr)) {
                       preempt_enable();
                       cpu_relax();
                       preempt_disable();
               }
       }=20

If "test_and_set_bit()" did not modify the lock while it's busy, a
simpler solution would do:

       while (test_and_set_bit(bitnum, addr)) {
               preempt_enable();
               cpu_relax();
               preempt_disable();
       }=20

>>Adding a test can cost only a few cycles, say max 4.
>=20
> But it reduces the performance of the commonly taken code path.
...
>>
>>By executing the atomic operation unconditionally, you kill
>>the cache line all the other waiting processors looping at.
>=20
> But note also that we optimize the common case, the case that the test an=
d=20
> set bit are successful. Only if it was not successful will we do non=20
> atomic loads. This is done to avoid cachelines bouncing while the lock is=
=20
> contended.

I can accept these arguments for small, not too much busy systems.

As the snooping and the cache line bouncing costs increases quadratically
with the system size...

Have you got some lock benchmarks to measure it?

Thanks,

Zolt=E1n Menyh=E1rt
