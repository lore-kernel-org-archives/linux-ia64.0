From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 09 Sep 2014 04:30:22 +0000
Subject: Re: bit fields && data tearing
Message-Id: <DD9D3F53-E3FF-4C13-B419-1200E934C530@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <21512.10628.412205.873477@gargle.gargle.HOWL> <20140904090952.GW17454@tucnak.redhat.com> <540859EC.5000407@hurleysoftware.com> <20140904175044.4697aee4@alan.etchedpixels.co.uk> <5408C0AB.6050801@hurleysoftware.com> <20140905001751.GL5001@linux.vnet.ibm.com> <1409883098.5078.14.camel@jarvis.lan> <5409243C.4080704@hurleysoftware.com> <20140905040645.GO5001@linux.vnet.ibm.com> <1410066442.12512.13.camel@jarvis.lan> <20140907162146.GK5001@linux.vnet.ibm.com> <1410116687.2027.19.camel@jarvis.lan> <540CC305.8010407@hurleysoftware.com> <1410155407.2027.29.camel@jarvis.lan> <540E3BFF.7080307@hurleysoftware.com> <1410231392.2028.15.camel@jarvis.lan>
In-Reply-To: <1410231392.2028.15.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Add a short member for proper alignment and one will probably pop out.

Sent from my tablet, pardon any formatting problems.

> On Sep 8, 2014, at 19:56, James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
>> On Mon, 2014-09-08 at 19:30 -0400, Peter Hurley wrote:
>> On 09/08/2014 01:50 AM, James Bottomley wrote:
>>>> Two things: I think that gcc has given up on combining adjacent writes,
>>>> perhaps because unaligned writes on some arches are prohibitive, so
>>>> whatever minor optimization was believed to be gained was quickly lost,
>>>> multi-fold. (Although this might not be the reason since one would
>>>> expect that gcc would know the alignment of the promoted store).
>>> 
>>> Um, gcc assumes architecturally correct alignment; that's why it pads
>>> structures.  Only when accessing packed structures will it use the
>>> lowest unit load/store.
>>> 
>>> if you have a struct { char a, char b }; and load first a then b with a
>>> constant gcc will obligingly optimise to a short store.
>> 
>> Um, please re-look at the test above. The exact test you describe is
>> coded above and compiled with gcc 4.6.3 cross-compiler for parisc using
>> the kernel compiler options.
>> 
>> In the generated code, please note the _absence_ of a combined write
>> to two adjacent byte stores.
> 
> So one version of gcc doesn't do it.  Others do because I've been
> surprised seeing it in assembly.
> 
>>>> But additionally, even if gcc combines adjacent writes _that are part
>>>> of the program flow_ then I believe the situation is no worse than
>>>> would otherwise exist.
>>>> 
>>>> For instance, given the following:
>>>> 
>>>> struct x {
>>>>    spinlock_t lock;
>>>>    long a;
>>>>    byte b;
>>>>    byte c;
>>>> };
>>>> 
>>>> void locked_store_b(struct x *p)
>>>> {
>>>>    spin_lock(&p->lock);
>>>>    p->b = 1;
>>>>    spin_unlock(&p->lock);
>>>>    p->c = 2;
>>>> }
>>>> 
>>>> Granted, the author probably expects ordered writes of
>>>>    STORE B
>>>>    STORE C
>>>> but that's not guaranteed because there is no memory barrier
>>>> ordering B before C.
>>> 
>>> Yes, there is: loads and stores may not migrate into or out of critical
>>> sections.
>> 
>> That's a common misconception.
>> 
>> The processor is free to re-order this to:
>> 
>>    STORE C
>>    STORE B
>>    UNLOCK
>> 
>> That's because the unlock() only guarantees that:
>> 
>> Stores before the unlock in program order are guaranteed to complete
>> before the unlock completes. Stores after the unlock _may_ complete
>> before the unlock completes.
>> 
>> My point was that even if compiler barriers had the same semantics
>> as memory barriers, the situation would be no worse. That is, code
>> that is sensitive to memory barriers (like the example I gave above)
>> would merely have the same fragility with one-way compiler barriers
>> (with respect to the compiler combining writes).
>> 
>> That's what I meant by "no worse than would otherwise exist".
> 
> Actually, that's not correct.  This is actually deja vu with me on the
> other side of the argument.  When we first did spinlocks on PA, I argued
> as you did: lock only a barrier for code after and unlock for code
> before.  The failing case is that you can have a critical section which
> performs an atomically required operation and a following unit which
> depends on it being performed.  If you begin the following unit before
> the atomic requirement, you may end up losing.  It turns out this kind
> of pattern is inherent in a lot of mail box device drivers: you need to
> set up the mailbox atomically then poke it.  Setup is usually atomic,
> deciding which mailbox to prime and actually poking it is in the
> following unit.  Priming often involves an I/O bus transaction and if
> you poke before priming, you get a misfire.
> 
>>>> I see no problem with gcc write-combining in the absence of
>>>> memory barriers (as long as alignment is still respected,
>>>> ie., the size-promoted write is still naturally aligned). The
>>>> combined write is still atomic.
>>> 
>>> Actual alignment is pretty irrelevant.  That's why all architectures
>>> which require alignment also have to implement misaligned traps ... this
>>> is a fundamental requirement of the networking code, for instance.
>>> 
>>> The main problem is gcc thinking there's a misalignment (or a packed
>>> structure).  That causes splitting of loads and stores and that destroys
>>> atomicity.
>> 
>> Yeah, the extra requirement I added is basically nonsense, since the
>> only issue is what instructions the compiler is emitting. So if compiler
>> thinks the alignment is natural and combines the writes -- ok. If the
>> compiler thinks the alignment is off and doesn't combine the writes --
>> also ok.
> 
> Yes, I think I can agree that the only real problem is gcc thinking the
> store or load needs splitting.
> 
> James
> 
> 
