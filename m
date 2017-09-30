From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Sat, 30 Sep 2017 09:20:02 +0000
Subject: Re: [PATCH REBASED 3/6] s390: Add __down_read_killable()
Message-Id: <20170930092002.GA4623@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
 <150670117817.23930.13068785028558453848.stgit@localhost.localdomain>
In-Reply-To: <150670117817.23930.13068785028558453848.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

On Fri, Sep 29, 2017 at 07:06:18PM +0300, Kirill Tkhai wrote:
> Similar to __down_write_killable(), and read killable primitive.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  arch/s390/include/asm/rwsem.h |   18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h

FWIW, while looking into this patch I realized that we never optimized our
rwsem primitives to make use of new atomic instructions.

The generic rwsem header file however does, since it uses atomic ops which
we did optimize. Even when compiling for old machines the generic version
generates better code. Therefore I will remove the 15 years old s390
implementation and switch to the generic version instead.

The same might be true for alpha and ia64...

