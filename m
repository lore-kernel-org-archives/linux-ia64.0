From: Jack Steiner <steiner@sgi.com>
Date: Thu, 30 Mar 2006 15:49:07 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060330154906.GA21663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 30, 2006 at 08:43:43AM -0700, David Mosberger-Tang wrote:
> On 3/30/06, Jack Steiner <steiner@sgi.com> wrote:
> 
> > Is this problem unique to SN systems
> 
> No, the same will happen on all other systems (that I know of).
> 
> > The BIOS reports that most
> > memory ranges support both CACHED & UNCACHED references. I _think_
> > this is correct.
> 
> That's correct.  The map shows the ways the page *can* be mapped, not
> the way it *should* be mapped.
> 
> It's strange that ACPI would prefer to use WC when WB mapping is
> possible.  They definitely need to pick one way and stick with it
> though.  As you say, mapping the same page with different cacheability
> is a no-no (and at least in theory, it should cause an MCA even on
> real hardware).

It does, at least on our chipset. If the chipset detects a simultaneous
UC & C reference, it generates a BUS error. It is surprising how
quickly this MCA occurs when we break the rules.



> 
>   --david
> 
> --
> Mosberger Consulting LLC, http://www.mosberger-consulting.com/

-- 
Jack


