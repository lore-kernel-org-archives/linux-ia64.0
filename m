From: Boqun Feng <boqun.feng@gmail.com>
Date: Wed, 06 Jan 2016 01:51:52 +0000
Subject: Re: [PATCH v2 15/32] powerpc: define __smp_xxx
Message-Id: <20160106015152.GA14605@fixme-laptop.cn.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-16-git-send-email-mst@redhat.com>
 <20160105013648.GA1256@fixme-laptop.cn.ibm.com>
 <20160105085117.GA11858@redhat.com>
 <20160105095341.GA5321@fixme-laptop.cn.ibm.com>
 <20160105180938-mutt-send-email-mst@redhat.com>
In-Reply-To: <20160105180938-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paul>

On Tue, Jan 05, 2016 at 06:16:48PM +0200, Michael S. Tsirkin wrote:
[snip]
> > > > Another thing is that smp_lwsync() may have a third user(other than
> > > > smp_load_acquire() and smp_store_release()):
> > > > 
> > > > http://article.gmane.org/gmane.linux.ports.ppc.embedded/89877
> > > > 
> > > > I'm OK to change my patch accordingly, but do we really want
> > > > smp_lwsync() get involved in this cleanup? If I understand you
> > > > correctly, this cleanup focuses on external API like smp_{r,w,}mb(),
> > > > while smp_lwsync() is internal to PPC.
> > > > 
> > > > Regards,
> > > > Boqun
> > > 
> > > I think you missed the leading ___ :)
> > > 
> > 
> > What I mean here was smp_lwsync() was originally internal to PPC, but
> > never mind ;-)
> > 
> > > smp_store_release is external and it needs __smp_lwsync as
> > > defined here.
> > > 
> > > I can duplicate some code and have smp_lwsync *not* call __smp_lwsync
> > 
> > You mean bringing smp_lwsync() back? because I haven't seen you defining
> > in asm-generic/barriers.h in previous patches and you just delete it in
> > this patch.
> > 
> > > but why do this? Still, if you prefer it this way,
> > > please let me know.
> > > 
> > 
> > I think deleting smp_lwsync() is fine, though I need to change atomic
> > variants patches on PPC because of it ;-/
> > 
> > Regards,
> > Boqun
> 
> Sorry, I don't understand - why do you have to do anything?
> I changed all users of smp_lwsync so they
> use __smp_lwsync on SMP and barrier() on !SMP.
> 
> This is exactly the current behaviour, I also tested that
> generated code does not change at all.
> 
> Is there a patch in your tree that conflicts with this?
> 

Because in a patchset which implements atomic relaxed/acquire/release
variants on PPC I use smp_lwsync(), this makes it have another user,
please see this mail:

http://article.gmane.org/gmane.linux.ports.ppc.embedded/89877

in definition of PPC's __atomic_op_release().


But I think removing smp_lwsync() is a good idea and actually I think we
can go further to remove __smp_lwsync() and let __smp_load_acquire and
__smp_store_release call __lwsync() directly, but that is another thing.

Anyway, I will modify my patch.

Regards,
Boqun

> 
> > > > >  	WRITE_ONCE(*p, v);						\
> > > > >  } while (0)
> > > > >  
> > > > > -#define smp_load_acquire(p)						\
> > > > > +#define __smp_load_acquire(p)						\
> > > > >  ({									\
> > > > >  	typeof(*p) ___p1 = READ_ONCE(*p);				\
> > > > >  	compiletime_assert_atomic_type(*p);				\
> > > > > -	smp_lwsync();							\
> > > > > +	__smp_lwsync();							\
> > > > >  	___p1;								\
> > > > >  })
> > > > >  
> > > > > -- 
> > > > > MST
> > > > > 
> > > > > --
> > > > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > > > the body of a message to majordomo@vger.kernel.org
> > > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > > > Please read the FAQ at  http://www.tux.org/lkml/
