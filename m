From: dann frazier <dannf@dannf.org>
Date: Sun, 13 Mar 2005 22:16:29 +0000
Subject: Re: conflicting per_cpu_init() defines on non-SMP
Message-Id: <1110752189.28262.3.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1110344998.9344.9.camel@localhost>
In-Reply-To: <1110344998.9344.9.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-03-09 at 09:38 -0800, Grant Grundler wrote:
> On Tue, Mar 08, 2005 at 10:09:58PM -0700, dann frazier wrote:
> > Is this the right way to approach a patch to fix this?
> 
> It looks right. But I'd expect arch/ia64/mm/discontig.c to use whats
> in the header file so everyone is using the same definition.
> 
> > +#ifdef CONFIG_SMP
> >  void *per_cpu_init(void)
> ...
> 
> ie move that bit to asm-ia64/percpu.h

Thanks Grant.
I took a closer look at Jesse's fixes, and he had already solved this in
a different way.  I'll stick with his method.

-- 
dann frazier <dannf@dannf.org>

