From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 28 Apr 2005 20:53:11 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504281348200.23705@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 28 Apr 2005, David Mosberger wrote:

> I'm unsure if it's a good idea to reduce the counter size.

We can still accomodate 2^24 = 16 million concurrent readers.

> Independent of that: using a name like "y" in a macro is bound to
> cause name collisions so it's a big no-no.  Then why not declare
> "y" as a "volatile u8 *" so you can avoid the explicit smp_wmb()?
> This is ia64-specific code after all.

I thought that a memory barrier was needed to insure that the clearing of
the lock becomes visible after changes done in the critical section?

y is defined in its own block.

May be better do inline asm with an .nta store?
