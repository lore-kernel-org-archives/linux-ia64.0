From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Aug 2002 16:14:32 +0000
Subject: Re: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Aug 2002 12:51:40 +0100, Matthew Wilcox <willy@debian.org> said:

  Matthew> The MCA handler is completely useless.

It's useful to me.

  Matthew> If I crash the machine and forget to clear the MCA dump in
  Matthew> firmware, at the next boot Linux dumps the registers (in a
  Matthew> hard-to-understand style) and hangs.

It shouldn't hang (and it doesn't on the Itanium & Itanium 2 systems
we have).  Sounds like something is off...

I agree that the output format is hard to understand, but a user-level
tool can fix that.  In my experience, the most useful value to look at
is CR[19], since it contains the IIP.  (It would be nice, though, to
have a beginners guide to decoding MCAs until there is better tools.)

	--david

