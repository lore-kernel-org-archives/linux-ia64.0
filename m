From: Andy Lutomirski <luto@myrealbox.com>
Date: Thu, 23 Sep 2004 07:17:25 +0000
Subject: Re: page fault scalability patch V8: [4/7] universally available
Message-Id: <41527885.8020402@myrealbox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0409201348070.4628@schroedinger.engr.sgi.com> <20040920205752.GH4242@wotan.suse.de> <200409211841.25507.vda@port.imtp.ilyichevsk.odessa.ua> <20040921154542.GB12132@wotan.suse.de>
In-Reply-To: <20040921154542.GB12132@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, benh@kernel.crashing.org, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, ak@muc.de, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

Andi Kleen wrote:
> On Tue, Sep 21, 2004 at 06:41:25PM +0300, Denis Vlasenko wrote:
> 
>>On Monday 20 September 2004 23:57, Andi Kleen wrote:
>>
>>>On Mon, Sep 20, 2004 at 01:49:20PM -0700, Christoph Lameter wrote:
>>>
>>>>On Mon, 20 Sep 2004, Denis Vlasenko wrote:
>>>>
>>>>
>>>>>I think it shouldn't be this way.
>>>>>
>>>>>OTOH for !CONFIG_386 case it makes perfect sense to have it inlined.
>>>>
>>>>Would the following revised patch be acceptable?
>>>
>>>You would need an EXPORT_SYMBOL at least. But to be honest your
>>>original patch was much simpler and nicer and cmpxchg is not called
>>>that often that it really matters. I would just ignore Denis' 
>>>suggestion and stay with the old patch.
>>
>>A bit faster approach (for CONFIG_386 case) would be using
> 
> 
> It's actually slower. Many x86 CPUs cannot predict indirect jumps
> and those that do cannot predict them as well as a test and jump.

Wouldn't alternative_input() choosing between a cmpxchg and a call be 
the way to go here?  Or is the overhead too high in an inline function?

(No patch included since I don't pretend to understand gcc's asm syntax 
at all.)

--Andy
