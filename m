From: Matthew Wilcox <willy@debian.org>
Date: Wed, 14 May 2003 18:05:45 +0000
Subject: Re: [Linux-ia64] kernel 2.5.69 doesn't compile for UP
Message-Id: <marc-linux-ia64-105590723705804@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705787@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705787@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 10:32:14AM -0700, David Mosberger wrote:
>   Matthew> Yuck.  The right way to do this is
>   Matthew> read_trylock(&tasklist_lock); The observant will have
>   Matthew> noted:
> 
>   Matthew> /* Where's read_trylock? */
> 
>   Matthew> in include/linux/spinlock.h but that doen't justify _not
>   Matthew> writing it_ when you need it.
> 
> You want to send me a patch? ;-)

Yes, I'd love to ;-)  I just need to fix your 2.5.69 patch so it'll compile :-P
$ find -type f |xargs grep compat_sys_setaffinity
./arch/ia64/ia32/ia32_entry.S:  data8 compat_sys_setaffinity
Binary file ./arch/ia64/ia32/ia32_entry.o matches
Binary file ./arch/ia64/ia32/built-in.o matches


Seriously, this is an attitude I see way too much of in this port.
Something's broken so it gets kludged inside arch/ia64 (or worse yet,
inside arch/ia64/sn/kernel/sn2/...) rather than fixing it properly.
Maybe it's a relic of the "secret beginnings" of this port, or maybe
people from certain companies have too narrow a focus, but it has to stop.
I think the attitude is starting to change but there's a lot of cruft
built up.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

