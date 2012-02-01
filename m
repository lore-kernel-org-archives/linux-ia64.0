From: Colin Walters <walters@verbum.org>
Date: Wed, 01 Feb 2012 16:37:45 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328114266.5355.44.camel@lenny>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
In-Reply-To: <20120201151918.GC16714@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 16:19 +0100, Jan Kara wrote:

> I've raised the issue with our GCC guys and they said to me that: "C does
> not provide such guarantee, nor can you reliably lock different
> structure fields with different locks if they share naturally aligned
> word-size memory regions.  The C++11 memory model would guarantee this,
> but that's not implemented nor do you build the kernel with a C++11
> compiler."

That's interesting.  So it seems like there are two solutions:

1) Use the same lock for a given bitfield
2) Split up the bitfield into different words


