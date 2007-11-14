From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 14 Nov 2007 23:17:46 +0000
Subject: Re: [patch 1/1] ia64: increase .data.patch offset
Message-Id: <87sl38pgbp.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
In-Reply-To: <200711130855.lAD8tBWd002649@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Simon" = Simon Horman <horms@verge.net.au> writes:

Simon> On Tue, Nov 13, 2007 at 02:26:07PM -0800, Andrew Morton wrote:
>> On Wed, 14 Nov 2007 09:07:45 +1100 Peter Chubb
>> <peterc@gelato.unsw.edu.au> wrote:
>> 
>> > >>>>> "akpm" = akpm <akpm@linux-foundation.org> writes:
>> > 
>> > akpm> From: Andrew Morton <akpm@linux-foundation.org> I get this:
>> > 
>> > akpm>
>> /opt/crosstool/gcc-3.4.5-glibc-2.3.6/ia64-unknown-linux-gnu/lib/gcc/ia64-unknown-linux-gnu/3.4.5/../../../../ia64-unknown-linux-gnu/bin/ld:
>> > akpm> section .data.patch [a000000000000500 -> a000000000000507]
>> > akpm> overlaps section .dynamic [a0000000000003c8 ->
>> a000000000000507]
>> > 
>> > If you switch to gcc 4.1 the patch section shrinks again and this
>> patch > isn't necessary.
>> 
>> It took me two solid days work to generate my current cross-compile
>> suite. Weep.
>> 
>> I spose I can keep this patch locally if that's the direction which
>> i64 wants to take.  But in that case ia64 should #error out early
>> if __GNUC__ is wrong.

Simon> Hi Peter,

Simon> can you be a little more specific about what toolchain you are
Simon> using?  I'm using crosstool but the most recent thing that it
Simon> seems to like is gcc-3.4.5 + glibc 2.3.6. I don't mind working
Simon> on crosstool a bit to get a newer gcc working, but I'd be
Simon> grateful of any advice on versions to avoid too much stabbing
Simon> in the dark.

I run the Debian packaged tools.  It's trivial then to generate cross
compilers, or native compilers.  What's more there are pre-packaged 
cross-toolchains at the emdebian site (although Itanium is a bit of an
also-ran, and at various times the prepackaged ones are inconsistent
-- for example the compiler package relies on libunwind which isn't
there, etc).

What I'll do today, is try a number of different compiler version
(it's realtively easy for me to do this), and email tomorrow which
ones compile a generic  kernel, and if I have time, which ones boot.

Currently,  I know  4.1 works (we use it for
http://www.gelato.unsw.edu.au/kerncomp ).  3.4.5 has the problem that
the patch section is too large to fit. 4.2 fails to compile
tiger_defconfig (problems with the PS2 mouse code that've already been
reported to the GCC maintainers).


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
