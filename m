From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 13 Sep 2005 19:44:29 +0000
Subject: Re: 2.6.14-rc1 ia64 rebuilds everything every time
Message-Id: <20050913194429.GA18319@mars.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <23363.1126593124@kao2.melbourne.sgi.com>
In-Reply-To: <23363.1126593124@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 13, 2005 at 07:34:44PM +1000, Peter Chubb wrote:
> >>>>> "Keith" = Keith Owens <kaos@sgi.com> writes:
> 
> 
> Keith> Best solution: remove (and forbid) recursive definitions in
> Keith> asm-offset.c.
> 
> Unfortunately,I'm not sure that's possible.
> 
> 
> Keith> Kludge 2: Build arch/$(ARCH)/kernel/asm-offsets.s as a
> Keith> temporary file then check if it has changed or not, only
> Keith> updating the real arch/$(ARCH)/kernel/asm-offsets.s if there is
> Keith> any change.
> 
> This is what used to happen.
What actually used to happen was that asm-offsets.h seldom was rebuild
despite included file had changed in the meantime.
When it then got rebuild - then we did the "has file changed" trick.

That I can be convinced to add back. On the other hand this is no more
special than any other fundamental .h file - when it changes we
recompile was uses it.


The reason why it hit us hard with ia64 is that is gets rebuild due to
the circular dependency where the file used to build asm-offsets.h uses
asm-offsets.h.
If we solve that problem the 'recompile everything' issue disappear.

Tony already posted an ugly patch to solve most of this.
I agree fully with Tony this is an ugly patch - did I have better
ideas how to solve it I would have posted a patch.

	Sam
