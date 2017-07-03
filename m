From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 03 Jul 2017 10:18:28 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code and fix UB
Message-Id: <alpine.DEB.2.20.1707031211120.2188@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170621115318.2781-1-jslaby@suse.cz>
 <alpine.DEB.2.20.1706230017520.2221@nanos>
 <80af8d81-4522-de2d-8289-1ab46565505a@suse.cz>
In-Reply-To: <80af8d81-4522-de2d-8289-1ab46565505a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Will Deacon <will.deacon@arm.com>, Max Filippov <jcmvbkbc@gmail.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, x86@kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>, mingo@redhat.com, Catalin Marinas <catalin.marinas@arm.com>, dvhart@infradead.org, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-xtensa@linux-xtensa.org

On Mon, 26 Jun 2017, Jiri Slaby wrote:
> On 06/23/2017, 09:51 AM, Thomas Gleixner wrote:
> > On Wed, 21 Jun 2017, Jiri Slaby wrote:
> >> diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
> >> index f32b42e8725d..5bb2fd4674e7 100644
> >> --- a/arch/arm64/include/asm/futex.h
> >> +++ b/arch/arm64/include/asm/futex.h
> >> @@ -48,20 +48,10 @@ do {									\
> >>  } while (0)
> >>  
> >>  static inline int
> >> -futex_atomic_op_inuser(unsigned int encoded_op, u32 __user *uaddr)
> > 
> > That unsigned int seems to be a change from the arm64 tree in next. It's
> > not upstream and it'll cause a (easy to resolve) conflict.
> 
> Ugh, I thought the arm64 is in upstream already. Note that this patch
> just takes what is in this arm64 fix and makes it effective for all
> architectures. So I will wait with v2 until it merges upstream.

Ok.

> > Yes, we probably can't change that anymore, but at least we should make it
> > very explicit and add a comment to that effect.
> 
> Something like this or do you want a comment yet?
>         unsigned int op =         (encoded_op & 0x70000000) >> 28;
>         unsigned int cmp =        (encoded_op & 0x0f000000) >> 24;
>         int oparg = sign_extend32((encoded_op & 0x00fff000) >> 12, 12);
>         int cmparg = sign_extend32(encoded_op & 0x00000fff, 12);

Yes, that makes sense.

There is also the issue with the shift. See this thread for further
reference:

  http://lkml.kernel.org/r/alpine.DEB.2.20.1706282353190.1890@nanos

The gist is:

  "Anything using a shift value < 0 or > 31 will get crap as a
   result. Rightfully so because it's just undefined.

   Yes I know that the insanity of user space is unlimited, but anything
   attempting this is so broken that we cannot break it further by making
   that shift arg unsigned and actually limit it to 0-31"

So we should make that case explicit as well.

        if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28)) {
		if (oparg < 0 || oparg > 31)
			return -EINVAL;
                oparg = 1 << oparg;
	}

Thanks,

	tglx
