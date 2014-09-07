From: Peter Hurley <peter@hurleysoftware.com>
Date: Sun, 07 Sep 2014 20:41:41 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540CC305.8010407@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <21512.10628.412205.873477@gargle.gargle.HOWL>	 <20140904090952.GW17454@tucnak.redhat.com>	 <540859EC.5000407@hurleysoftware.com>	 <20140904175044.4697aee4@alan.etchedpixels.co.uk>	 <5408C0AB.6050801@hurleysoftware.com>	 <20140905001751.GL5001@linux.vnet.ibm.com>	 <1409883098.5078.14.camel@jarvis.lan> <5409243C.4080704@hurleysoftware.com>	 <20140905040645.GO5001@linux.vnet.ibm.com>	 <1410066442.12512.13.camel@jarvis.lan>	 <20140907162146.GK5001@linux.vnet.ibm.com> <1410116687.2027.19.camel@jarvis.lan>
In-Reply-To: <1410116687.2027.19.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>, paulmck@linux.vnet.ibm.com
Cc: "H. Peter Anvin" <hpa@zytor.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On 09/07/2014 03:04 PM, James Bottomley wrote:
> On Sun, 2014-09-07 at 09:21 -0700, Paul E. McKenney wrote:
>> On Sat, Sep 06, 2014 at 10:07:22PM -0700, James Bottomley wrote:
>>> On Thu, 2014-09-04 at 21:06 -0700, Paul E. McKenney wrote:
>>>> On Thu, Sep 04, 2014 at 10:47:24PM -0400, Peter Hurley wrote:
>>>>> Hi James,
>>>>>
>>>>> On 09/04/2014 10:11 PM, James Bottomley wrote:
>>>>>> On Thu, 2014-09-04 at 17:17 -0700, Paul E. McKenney wrote:
>>>>>>> +And there are anti-guarantees:
>>>>>>> +
>>>>>>> + (*) These guarantees do not apply to bitfields, because compilers often
>>>>>>> +     generate code to modify these using non-atomic read-modify-write
>>>>>>> +     sequences.  Do not attempt to use bitfields to synchronize parallel
>>>>>>> +     algorithms.
>>>>>>> +
>>>>>>> + (*) Even in cases where bitfields are protected by locks, all fields
>>>>>>> +     in a given bitfield must be protected by one lock.  If two fields
>>>>>>> +     in a given bitfield are protected by different locks, the compiler's
>>>>>>> +     non-atomic read-modify-write sequences can cause an update to one
>>>>>>> +     field to corrupt the value of an adjacent field.
>>>>>>> +
>>>>>>> + (*) These guarantees apply only to properly aligned and sized scalar
>>>>>>> +     variables.  "Properly sized" currently means "int" and "long",
>>>>>>> +     because some CPU families do not support loads and stores of
>>>>>>> +     other sizes.  ("Some CPU families" is currently believed to
>>>>>>> +     be only Alpha 21064.  If this is actually the case, a different
>>>>>>> +     non-guarantee is likely to be formulated.)
>>>>>>
>>>>>> This is a bit unclear.  Presumably you're talking about definiteness of
>>>>>> the outcome (as in what's seen after multiple stores to the same
>>>>>> variable).
>>>>>
>>>>> No, the last conditions refers to adjacent byte stores from different
>>>>> cpu contexts (either interrupt or SMP).
>>>>>
>>>>>> The guarantees are only for natural width on Parisc as well,
>>>>>> so you would get a mess if you did byte stores to adjacent memory
>>>>>> locations.
>>>>>
>>>>> For a simple test like:
>>>>>
>>>>> struct x {
>>>>> 	long a;
>>>>> 	char b;
>>>>> 	char c;
>>>>> 	char d;
>>>>> 	char e;
>>>>> };
>>>>>
>>>>> void store_bc(struct x *p) {
>>>>> 	p->b = 1;
>>>>> 	p->c = 2;
>>>>> }
>>>>>
>>>>> on parisc, gcc generates separate byte stores
>>>>>
>>>>> void store_bc(struct x *p) {
>>>>>    0:	34 1c 00 02 	ldi 1,ret0
>>>>>    4:	0f 5c 12 08 	stb ret0,4(r26)
>>>>>    8:	34 1c 00 04 	ldi 2,ret0
>>>>>    c:	e8 40 c0 00 	bv r0(rp)
>>>>>   10:	0f 5c 12 0a 	stb ret0,5(r26)
>>>>>
>>>>> which appears to confirm that on parisc adjacent byte data
>>>>> is safe from corruption by concurrent cpu updates; that is,
>>>>>
>>>>> CPU 0                | CPU 1
>>>>>                      |
>>>>> p->b = 1             | p->c = 2
>>>>>                      |
>>>>>
>>>>> will result in p->b = 1 && p->c = 2 (assume both values
>>>>> were 0 before the call to store_bc()).
>>>>
>>>> What Peter said.  I would ask for suggestions for better wording, but
>>>> I would much rather be able to say that single-byte reads and writes
>>>> are atomic and that aligned-short reads and writes are also atomic.
>>>>
>>>> Thus far, it looks like we lose only very old Alpha systems, so unless
>>>> I hear otherwise, I update my patch to outlaw these very old systems.
>>>
>>> This isn't universally true according to the architecture manual.  The
>>> PARISC CPU can make byte to long word stores atomic against the memory
>>> bus but not against the I/O bus for instance.  Atomicity is a property
>>> of the underlying substrate, not of the CPU.  Implying that atomicity is
>>> a CPU property is incorrect.

To go back to this briefly, while it's true that atomicity is not
a CPU property, atomicity is not possible if the CPU is not cooperating.

>> OK, fair point.
>>
>> But are there in-use-for-Linux PARISC memory fabrics (for normal memory,
>> not I/O) that do not support single-byte and double-byte stores?
> 
> For aligned access, I believe that's always the case for the memory bus
> (on both 32 and 64 bit systems).  However, it only applies to machine
> instruction loads and stores of the same width..  If you mix the widths
> on the loads and stores, all bets are off.  That means you have to
> beware of the gcc penchant for coalescing loads and stores: if it sees
> two adjacent byte stores it can coalesce them into a short store
> instead ... that screws up the atomicity guarantees.

Two things: I think that gcc has given up on combining adjacent writes,
perhaps because unaligned writes on some arches are prohibitive, so
whatever minor optimization was believed to be gained was quickly lost,
multi-fold. (Although this might not be the reason since one would
expect that gcc would know the alignment of the promoted store).

But additionally, even if gcc combines adjacent writes _that are part
of the program flow_ then I believe the situation is no worse than
would otherwise exist.

For instance, given the following:

struct x {
	spinlock_t lock;
	long a;
	byte b;
	byte c;
};

void locked_store_b(struct x *p)
{
	spin_lock(&p->lock);
	p->b = 1;
	spin_unlock(&p->lock);
	p->c = 2;
}

Granted, the author probably expects ordered writes of
	STORE B
	STORE C
but that's not guaranteed because there is no memory barrier
ordering B before C.

I see no problem with gcc write-combining in the absence of
memory barriers (as long as alignment is still respected,
ie., the size-promoted write is still naturally aligned). The
combined write is still atomic.

Regards,
Peter Hurley
