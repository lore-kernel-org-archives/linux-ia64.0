From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 17 Jan 2003 21:19:46 +0000
Subject: Re: [Linux-ia64] Error compiling 2.4.20 for i386
Message-Id: <marc-linux-ia64-105590709805715@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I was under the mistaken impression that the ia64 patch for 2.4.18 and
> beyond would not break ia32. I am looking for a way to support both ia32 and
> ia64 from a single kernel source. Is there a plan for the ia64 patch to
> support this model?

No, I don't have a plan to support both ia32 and ia64 with the ia64
patch.  I just don't have the time, equipment, or knowledge to maintain
the ia32 side of that equation.  The ACPI update I mentioned is one
big issue.  Another is the PCI BAR sizing problem -- ia64 requires
an approach that is unsafe on i386.

Of course, I do try to reduce the size of the ia64 patch by pushing
things upstream, and if it were ever reduced to zero, or to only
arch/ia64 things, then i386 should Just Work.  That's not likely to
happen anytime soon, though.

> However, I'm getting
> this link error now...
> 
> net/network.o(.debug_info+0x6f4b26): undefined reference to `L5661'

I don't have a clue on this one.  I'd try a clean build from scratch
to make sure everything was built by the same toolchain, with the same
options, etc.

Bjorn


