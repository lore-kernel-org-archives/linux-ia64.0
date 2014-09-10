From: Rob Landley <rob@landley.net>
Date: Wed, 10 Sep 2014 21:10:56 +0000
Subject: Re: bit fields && data tearing
Message-Id: <CAOS_Y6SA_TZUgr7nHiA_0EUuL9J9rTMboRTMBCfcoiHGONXYhw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
	<54079B70.4050200@hurleysoftware.com>
	<1409785893.30640.118.camel@pasglop>
	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>
	<1409824374.4246.62.camel@pasglop>
	<5408E458.3@zytor.com>
	<54090AF4.7060406@hurleysoftware.com>
	<54091B30.7080100@zytor.com>
	<5409D76D.2070203@hurleysoftware.com>
	<5409D9C0.7030403@zytor.com>
	<20140908185240.21f52ca0@alan.etchedpixels.co.uk>
	<5410B1FE.9090504@zytor.com>
In-Reply-To: <5410B1FE.9090504@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Peter Hurley <peter@hurleysoftware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@aculab.com>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On Wed, Sep 10, 2014 at 3:18 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 09/08/2014 10:52 AM, One Thousand Gnomes wrote:
>>
>> I think the whole "removing Alpha EV5" support is basically bonkers. Just
>> use set_bit in the tty layer. Alpha will continue to work as well as it
>> always has done and you won't design out support for any future processor
>> that turns out not to do byte aligned stores.
>>
>
> I think it's pretty safe to say such a processor is unlikely to ever be
> created, for the same reason there weren't any 48-bit computers when
> 32-bit computers ran out of steam: it caused more problems than it
> solved, and Alpha pretty much proved that.  The engineering advantages
> would have to be so overwhelmingly in favor for someone to want to walk
> down that road again.
>
>         -hpa

I note for the record I'm trying to get basic Alpha support working in
http://landley.net/aboriginal/about.html now that qemu at least offers
a qemu-system-alpha, and if I do get it working I may take a stab at
adding alpha support to musl-libc.

It's not just that I want to get cross platform testing of package
builds working on a convenient/reproducible/portable way on as many
different targets as I can. My project is designed the way it is
because I think losing the ability to reproduce things from first
principles (and thus understand why it was done that way in the first
place) is a _bad_idea_. And an increasingly real-world problem, see
http://wrttn.in/04af1a for example. (And the way NASA lost the plans
for the Saturn V rocket... In fact scientists' general disinclination
to reproduce old experimental results to see if they were actually
true or not comes up on a regular basis, most recent I saw was
http://www.theglobeandmail.com/life/health-and-fitness/health/the-curious-case-of-the-cyclists-unshaved-legs/article20370814/
)

Of course Peter has consistently dismissed my concerns as "academic":

http://lkml.iu.edu/hypermail/linux/kernel/0802.1/4400.html

Personally, I hope the projects I work on _do_ outlive me, an try to
make it easy for newbies to recapitulate phylogeny. That's why I
thought requiring perl dependencies to build was a bad idea, and why I
thought removing 386 support entirely (instead of restricting it to
UP) was a bad idea. The idea that Linux no longer needs to build on
the original machine Linus designed it for, and now it no longer needs
to work on the machine the "arch" directory was created for (and the
first 64 bit machine)... These positions would appear to have a single
consistent proponent, with whom I disagree.

Oh well, just wanted to get that out there,

Rob
