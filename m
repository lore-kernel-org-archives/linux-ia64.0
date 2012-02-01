From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 19:09:06 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFzzaWM=EWsK1hRho27b5ePEYNkzEnqce-DmCQ3kL1w9ZA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
 <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
 <20120201.130905.1131458895704793597.davem@davemloft.net> <4F298865.5000409@redhat.com>
In-Reply-To: <4F298865.5000409@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Law <law@redhat.com>
Cc: David Miller <davem@davemloft.net>, matz@suse.de, jkosina@suse.cz, walters@verbum.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 10:45 AM, Jeff Law <law@redhat.com> wrote:
>
> Torvald Riegel & I were told that was kernel policy when we brought up the
> upcoming bitfield semantic changes with some of the linux kernel folks last
> year.

Btw, one reason this is true is that the bitfield ordering/packing is
so unspecified that using bitfields sometimes is just way more pain
than you get. Some people have tried to use bitfields for various IO
data structures (think laying out bits in memory to match some
particular layout of some disk controller result structure). It's
always a total disaster, because you have another whole level of
architecture-specific bit ordering (in *addition* to all the normal
byte order issues).

That's not a compiler issue, that's just the nature of the beast.
It's just another reason why the kernel often ends up then doing bit
masking by hand.

But *all* that said, we do have a metric buttload of bitfields in the
kernel. It's not some really unusual feature. It does get used a lot,
despite all the reasons why some particular code might not use
bitfields.

We have a lot of code, there's still a lot of situations left where
bitfields are just really convenient.

                    Linus
