From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 09 Oct 2003 01:24:47 +0000
Subject: Re: [PATCH] Fix IA64 build with separate source and build trees.
Message-Id: <marc-linux-ia64-106566272413398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106565735409518@msgid-missing>
In-Reply-To: <marc-linux-ia64-106565735409518@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Matthew" = Matthew Wilcox <willy@debian.org> writes:

Matthew> On Thu, Oct 09, 2003 at 09:52:12AM +1000, Peter Chubb wrote:
>> Hi David, This patch against 2.6.0-test7 fixes building in a
>> separate output directory.  Without it, offsets.h isn't built, and
>> the check-gas and toolchain-flags sscripts aren't found.

Matthew> I'm more curious than anything ...

>> +arch/$(ARCH)/kernel/asm-offsets.s: include/asm
>> include/linux/version.h
Matthew> [...]
>> -arch/ia64/kernel/asm-offsets.s: include/asm-ia64/.offsets.h.stamp
>> +arch/ia64/kernel/asm-offsets.s:
>> include/asm-$(ARCH)/.offsets.h.stamp

Matthew> What's the advantage to using $(ARCH) here?  Since this is in
Matthew> an arch directory, we already know our $ARCH.  And if we are
Matthew> going to use it, shouldn't it be used everywhere?


Main advantage is it makes this bit of code almost identical between
architectures, so that when someone updates it a simple grep will find
it everywhere.  And yes, it should be ${ARCH} everywhere htat there's
identical code between architectures (which means everywhere, for
simplicity as to know when to use what)

Peter C
