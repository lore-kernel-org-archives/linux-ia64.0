From: Matthew Wilcox <willy@debian.org>
Date: Wed, 14 May 2003 14:16:49 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 03:31:08PM +0200, Eric Piel wrote:
> Hello,
> There is a compile error if not compiling for SMP:

> +#ifdef CONFIG_SMP
>  	if (!tasklist_lock.write_lock)
> +#endif
>  		read_lock(&tasklist_lock);

Yuck.  The right way to do this is read_trylock(&tasklist_lock);
The observant will have noted:

#define write_trylock(lock)     ({preempt_disable();_raw_write_trylock(lock) ? \
                                1 : ({preempt_enable(); 0;});})

/* Where's read_trylock? */

in include/linux/spinlock.h but that doen't justify _not writing it_
when you need it.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

