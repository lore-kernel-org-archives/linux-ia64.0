From: Matthew Wilcox <willy@debian.org>
Date: Wed, 14 May 2003 13:29:00 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705786@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 13, 2003 at 11:33:33PM -0700, Grant Grundler wrote:
> On Wed, May 14, 2003 at 12:32:17PM +1000, Martin Pool wrote:
> > But you also need to know which disk to write to, and where.
> ...
> > If any of this got screwed up, you might
> > write your dump over /home instead -- and then rather than a possibly
> > once-off kernel crash, you've lost lots of data.
> 
> I'll take that risk since I've never seen it nor heard of it
> happening with HPUX after ~6 years of working HPUX IO subsystems.
> I'm sure HPUX has done things to help mitigate that risk.
> (like storing paths in NVRAM or some other hard to reach place.)
> All problem reports (including memory corruption problems) came with
> crash dumps.

But those HPUX systems were on PA which has PDC which can write to
the disc.  The problem on ia64 is that EFI can't after the OS has started.

I seem to remember lamont eulogising the MPE way of doing crashdumps
-- Transfer of Control really does transfer control to a completely
different kernel that does the dump for you.  That seems a much better
way of doing things to me.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

