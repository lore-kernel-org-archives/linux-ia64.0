From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Thu, 03 Nov 2005 18:20:41 +0000
Subject: Re: [patch] align signal-frame even when not using alternate signal-stack
Message-Id: <ed5aea430511031020m5c354349u33f3ad9aa0a0ec66@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051103064019.5B552B3421@localhost.localdomain>
In-Reply-To: <20051103064019.5B552B3421@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/2/05, Keith Owens <kaos@sgi.com> wrote:
> On Wed, 2 Nov 2005 22:40:19 -0800 (PST),
> davidm@mail.mostang.com (David Mosberger-Tang) wrote:
> >At the moment, attempting to invoke a signal-handler on the normal
> >stack is guaranteed to fail if the stack-pointer happens not to be
> >16-byte aligned.
>
> Itanium Software Conventions and Runtime Architecture Guide, section
> 7.1 says that the stack pointer must always be aligned on a 16 byte
> boundary.  What software is not using 16 byte alignment for the stack?

Buggy software...

This really is more a "ease debugging" kind of thing.  Clearly you're
in a heap of trouble once your stack-pointer is misaligned, but with
the old behavior, that was aggravated by triggering an infinite series
of nested signals, which makes it quite hard to just stop the process
(plus it may eat lots of memory if the stack limit is large).

On top of that, I don't think it makes a lot of sense to force 16-byte
alignment for delivery on alternate signal-stacks and not do so for
the normal stack.  I don't have access to the very earliest ia64-linux
patches anymore (prior to 2000, when things went public), but I'm
pretty sure this was a historical accident.

Thanks,

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
