From: Matthew Wilcox <willy@debian.org>
Date: Fri, 24 Oct 2003 18:27:16 +0000
Subject: Re: [PATCH] Re: Gate DSO not building properly?
Message-Id: <marc-linux-ia64-106702004804458@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106679437709356@msgid-missing>
In-Reply-To: <marc-linux-ia64-106679437709356@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 24, 2003 at 02:21:04PM +0200, Andreas Schwab wrote:
> Matthew Wilcox <willy@debian.org> writes:
> > I'd have more sympathy for the latter view if it could lead to subtle
> > bugs, but I've been unable to come up with a situation where it makes
> > a difference.
> 
> a &~ x-1

tmp.c:12: warning: suggest parentheses around + or - in operand of &

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
