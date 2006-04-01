From: Andi Kleen <ak@suse.de>
Date: Sat, 01 Apr 2006 02:44:09 +0000
Subject: Re: [patch] avoid unaligned access when accessing poll stack
Message-Id: <200604010444.09747.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0sloytyj5.fsf@jaguar.mkp.net> <yq0odzmtwni.fsf@jaguar.mkp.net> <20060401023538.GB3157@gaz.sfgoth.com>
In-Reply-To: <20060401023538.GB3157@gaz.sfgoth.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mitchell Blank Jr <mitch@sfgoth.com>
Cc: Jes Sorensen <jes@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Saturday 01 April 2006 04:35, Mitchell Blank Jr wrote:

>   * I also changed "size" to be unsigned since that makes more sense and
>     is less prone to overflow bugs.  I'm also a little scared by the
>     "kmalloc(6 * size)" since that type of call is a classic multiply-overflow
>     security hole (hence libc's calloc() API).  However "size" is constrained
>     by fdt->max_fdset so I think it isn't exploitable.  The kernel doesn't
>     have an overflow-safe API for kmalloc'ing arrays, does it?

kcalloc. But it's slow since it memsets.

-Andi

