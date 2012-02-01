From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 18:57:57 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFyFQCVDod6z1zihK9mnow-BOnD=rJJwj=1_v91efMGmoA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>
 <alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz> <Pine.LNX.4.64.1202011818570.25409@wotan.suse.de>
 <20120201.130905.1131458895704793597.davem@davemloft.net>
In-Reply-To: <20120201.130905.1131458895704793597.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: matz@suse.de, jkosina@suse.cz, walters@verbum.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 10:09 AM, David Miller <davem@davemloft.net> wrote:
>
> Personally I've avoided C bitfields like the plague in any code I've
> written.

I do agree with that. The kernel largely tries to avoid bitfields,
usually because we have some really strict rules about different
bitfields, but also because initialization of bitfields tends to
result in gcc generating an incredible mess of the code (while
"explicit bits" allows us to just set all the fields in one go, and
know what the result is).

So core kernel data structures tend to be things like "unsigned long",
together with our various bitop functions that have explicit atomicity
(or non-atomicity) guarantees on a bit-per-bit basis.

Sometimes bitfields are really convenient, though, and allow for much
more natural syntax.

I'm not surprised this issue came up in a filesystem, for example.

                          Linus
