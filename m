From: Andreas Jaeger <aj@suse.de>
Date: Tue, 18 Sep 2001 09:03:52 +0000
Subject: Re: [Linux-ia64] PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805193@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805193@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen <jes@sunsite.dk> writes:

>>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:
>
>>>>>> On Mon, 17 Sep 2001 10:02:14 -0600, Doug Beattie <dbb@caldera.com> said:
> Doug> Your reponse is welcome and invited.  The LSB and FHS groups are
> Doug> trying to better address the coexistance of 32 and 64 bit in the
> Doug> 64 bit Itanium environment.
>
> Doug> Please review the following proposal and respond to the
> Doug> "lsb-spec@lists.linuxbase.org" and
> Doug> "lsb-discuss@lists.linuxbase.org" mail lists.
>
> David> When will people learn that for Linux, source compatibility is
> David> just as important as binary compatibility?  For IA-64 Linux,
> David> the decision was made that native libraries go into /lib etc
> David> and that legacy libraries go somewhere else
> David> (/usr/i386-*-linux/lib, commonly).
>
> Not to mention that ld.so has already been fixed to handle searching
> through library directories containing libraries for a different
> architecture than ld.so is running on itself. Hence the whole point of
> ia32 binaries being unable to cope with ia64 binaries in /lib is
> completely useless.
>
> It would have been extremely nice if the people who decided to write
> this standard had started out by asking the people who did the
> implementation work how the architecture really works and what
> experience has been gained in these areas already.

Please read the email that I've send some minutes, George forgot to
append one paragraph.  We didn't want to suggest that ia64 was changed
- the purpose was to unify existing practice and decide on a way how
to handle it with newer 64 bit platforms that have a mixed 32-bit and
64-bit userland.

For ia64 the situation is a bit different than for PPC64, S390, x86-64
and MIPS.

Andreas

-- 
 Andreas Jaeger
  SuSE Labs aj@suse.de
   private aj@arthur.inka.de
    http://www.suse.de/~aj

