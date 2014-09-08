From: Peter Hurley <peter@hurleysoftware.com>
Date: Mon, 08 Sep 2014 22:47:35 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540E3207.7090007@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>	<54079B70.4050200@hurleysoftware.com>	<1409785893.30640.118.camel@pasglop>	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>	<1409824374.4246.62.camel@pasglop>	<5408E458.3@zytor.com>	<54090AF4.7060406@hurleysoftware.com>	<54091B30.7080100@zytor.com>	<5409D76D.2070203@hurleysoftware.com>	<5409D9C0.7030403@zytor.com> <20140908185240.21f52ca0@alan.etchedpixels.co.uk> <540DEE6C.2060904@zytor.com>
In-Reply-To: <540DEE6C.2060904@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On 09/08/2014 01:59 PM, H. Peter Anvin wrote:
> On 09/08/2014 10:52 AM, One Thousand Gnomes wrote:
>> On Fri, 05 Sep 2014 08:41:52 -0700
>> "H. Peter Anvin" <hpa@zytor.com> wrote:
>>
>>> On 09/05/2014 08:31 AM, Peter Hurley wrote:
>>>>
>>>> Which is a bit ironic because I remember when Digital had a team
>>>> working on emulating native x86 apps on Alpha/NT.
>>>>
>>>
>>> Right, because the x86 architecture was obsolete and would never scale...
>>
>> Talking about "not scaling" can anyone explain how a "you need to use
>> set_bit() and friends" bug report scaled into a hundred message plus
>> discussion about ambiguous properties of processors (and nobody has
>> audited all the embedded platforms we support yet, or the weirder ARMs)
>> and a propsal to remove Alpha support.
>>
>> Wouldn't it be *much* simpler to do what I suggested in the first place
>> and use the existing intended for purpose, deliberately put there,
>> functions for atomic bitops, because they are fast on sane processors and
>> they work on everything else.
>>
>> I think the whole "removing Alpha EV5" support is basically bonkers. Just
>> use set_bit in the tty layer. Alpha will continue to work as well as it
>> always has done and you won't design out support for any future processor
>> that turns out not to do byte aligned stores.
>>
>> Alan
>>
> 
> Is *that* what we are talking about?  I was added to this conversation
> in the middle where it had already generalized, so I had no idea.

No, this is just what brought this craziness to my attention.

For example, byte- and short-sized circular buffers could not possibly
be safe either, when the head nears the tail.

Who has audited global storage and ensured that _every_ byte-sized write
doesn't happen to be adjacent to some other storage that may not happen
to be protected by the same (or any) lock?

Regards,
Peter Hurley



