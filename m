From: Rik van Riel <riel@redhat.com>
Date: Wed, 09 Jan 2013 21:41:23 +0000
Subject: Re: [PATCH 7/8] mm: use vm_unmapped_area() on powerpc architecture
Message-Id: <50EDE403.4070208@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-8-git-send-email-walken@google.com> <1357697739.4838.30.camel@pasglop> <CANN689EJV_7Q7J4j1ttDxZuqbwD53PAuCHb5DhiE-AVbmNSR7Q@mail.gmail.com> <1357702376.4838.32.camel@pasglop> <20130109112313.GA4905@google.com>
In-Reply-To: <20130109112313.GA4905@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michel Lespinasse <walken@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 01/09/2013 06:23 AM, Michel Lespinasse wrote:
> On Wed, Jan 09, 2013 at 02:32:56PM +1100, Benjamin Herrenschmidt wrote:
>> Ok. I think at least you can move that construct:
>>
>> +               if (addr < SLICE_LOW_TOP) {
>> +                       slice = GET_LOW_SLICE_INDEX(addr);
>> +                       addr = (slice + 1) << SLICE_LOW_SHIFT;
>> +                       if (!(available.low_slices & (1u << slice)))
>> +                               continue;
>> +               } else {
>> +                       slice = GET_HIGH_SLICE_INDEX(addr);
>> +                       addr = (slice + 1) << SLICE_HIGH_SHIFT;
>> +                       if (!(available.high_slices & (1u << slice)))
>> +                               continue;
>> +               }
>>
>> Into some kind of helper. It will probably compile to the same thing but
>> at least it's more readable and it will avoid a fuckup in the future if
>> somebody changes the algorithm and forgets to update one of the
>> copies :-)
>
> All right, does the following look more palatable then ?
> (didn't re-test it, though)

Looks equivalent. I have also not tested :)

> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

