From: Peter Hurley <peter@hurleysoftware.com>
Date: Tue, 09 Sep 2014 11:18:22 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540EE1FE.3090706@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>	<54079B70.4050200@hurleysoftware.com>	<1409785893.30640.118.camel@pasglop>	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>	<1409824374.4246.62.camel@pasglop>	<5408E458.3@zytor.com>	<54090AF4.7060406@hurleysoftware.com>	<54091B30.7080100@zytor.com>	<5409D76D.2070203@hurleysoftware.com>	<5409D9C0.7030403@zytor.com>	<20140908185240.21f52ca0@alan.etchedpixels.co.uk>	<540DEE6C.2060904@zytor.com> <20140908201722.66bc6492@alan.etchedpixels.co.uk>
In-Reply-To: <20140908201722.66bc6492@alan.etchedpixels.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On 09/08/2014 03:17 PM, One Thousand Gnomes wrote:
>>> I think the whole "removing Alpha EV5" support is basically bonkers. Just
>>> use set_bit in the tty layer. Alpha will continue to work as well as it
>>> always has done and you won't design out support for any future processor
>>> that turns out not to do byte aligned stores.
>>>
>>> Alan
>>>
>>
>> Is *that* what we are talking about?  I was added to this conversation
>> in the middle where it had already generalized, so I had no idea.
>>
>> 	-hpa
> 
> Yes there are some flags in the tty layer that are vulnerable to this
> (although they've been vulnerable to it and missing a lock since last
> century with no known ill effects).

That observation cuts both ways; I'm willing to leave it vulnerable with
'no known ill effects' on the Alpha.
 

