From: Matthew Wilcox <willy@debian.org>
Date: Fri, 22 Aug 2003 02:25:51 +0000
Subject: Re: build problems/questions (2.6.0-test3)
Message-Id: <marc-linux-ia64-106151933415932@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106151574613417@msgid-missing>
In-Reply-To: <marc-linux-ia64-106151574613417@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 21, 2003 at 06:28:50PM -0700, Randy.Dunlap wrote:
> I'm seeing some build problems and want to see if they are just my
> problems.  Shoule these build OK on ia64 or are they all just
> dont-cares for ia64?
> 
> 1.  driver/block/floppy.c

Don't-care.  Should be made unselectable in Kconfig.  No ia64 boxes have
shipped with that kind of floppy drive (ide-floppy on the first boxes).

> 2.  drivers/char/nvram.c ?? (x86-ism)

I doubt anyone put an mc146818rtc chip in an ia64 box.

> 3.  drivers/char/hangcheck.c ?

Do you mean drivers/char/hangcheck-timer.c?  This looks x86-specific to me,
monotonic_clock() is in arch/i386 and arch/x86_64 only.

> 4.  ISA PNP support?

Definitely no ISA on these boxes.  Shouldn't ISAPNP depend on ISA in Kconfig?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
