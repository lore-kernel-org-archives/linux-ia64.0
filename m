From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Sat, 30 Sep 2017 10:36:12 +0000
Subject: Re: [PATCH REBASED 3/6] s390: Add __down_read_killable()
Message-Id: <20170930123612.0fb250fe@mschwideX1>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
        <150670117817.23930.13068785028558453848.stgit@localhost.localdomain>
        <20170930092002.GA4623@osiris>
In-Reply-To: <20170930092002.GA4623@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

On Sat, 30 Sep 2017 11:20:02 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> On Fri, Sep 29, 2017 at 07:06:18PM +0300, Kirill Tkhai wrote:
> > Similar to __down_write_killable(), and read killable primitive.
> >=20
> > Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> > ---
> >  arch/s390/include/asm/rwsem.h |   18 ++++++++++++++++--
> >  1 file changed, 16 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwse=
m.h =20
>=20
> FWIW, while looking into this patch I realized that we never optimized our
> rwsem primitives to make use of new atomic instructions.
>=20
> The generic rwsem header file however does, since it uses atomic ops which
> we did optimize. Even when compiling for old machines the generic version
> generates better code. Therefore I will remove the 15 years old s390
> implementation and switch to the generic version instead.

Take care not to conflict with the queued spinlock/rwlock patches on the
features branch.=20

https://git.kernel.org/pub/scm/linux/kernel/git/s390/linux.git/commit/?h=FE=
atures&id=EB3b7b848fb3dd00f7a57d633d4ae4d194aa7865

Me thinks that what you have in mind is already done.

--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

