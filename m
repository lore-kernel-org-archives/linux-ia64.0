From: Matthew Wilcox <willy@debian.org>
Date: Fri, 24 Oct 2003 12:06:42 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106699727807797@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 24, 2003 at 11:07:22AM +0100, Nick Clifton wrote:
> >  		   && (attr &~ ssect->attr &~ SHF_MERGE &~ SHF_STRINGS) = 0)
> 
> I would appreciate it if you could add a space between the '&' and the
> '~'.  These are separate operators and should not be juxtaposed like
> that.  I know that this is not part of your original patch, but since
> we are modifying this area of code, I think that it would be a good
> idea to clean this up.

There's two schools of thought on this one ... it really depends how
you prefer to think about it.  Myself, I'm used to ARM with its BIC
(BIt Clear) instruction, which I translate to the &~ "operator".  I
know some people prefer to think of it as "invert all the bits and mask"
but that's just less intuitive for me.

I'd have more sympathy for the latter view if it could lead to subtle
bugs, but I've been unable to come up with a situation where it makes
a difference.  The type promotion rules seem to prevent inadvertent bits
being cleared.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
