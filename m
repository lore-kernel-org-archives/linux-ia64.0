From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 22:54:23 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005329@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Mar 2001 12:38:47 -0800, Jim Wilson <wilson@cygnus.com> said:

  Jim> Also, if gcc does have to change, then I need a good
  Jim> explanation of why.  I can't go to the other gcc developers and
  Jim> tell them that the way we've been doing things for 3-4 years is
  Jim> now suddenly wrong, without also explaining exactly why it is
  Jim> wrong.  As yet, I do not have any explanation I can use.

Fair enough.  But I hope are not discounting the usefulness of a
short-circuit return just because gcc happens not to generate such
code at the moment.  It's certainly a common idiom for assembly
programming and clearly useful.  So, the example that Keith gave is
one valid example:

	mov rp = common_exit_path_code
	br.call b6 = handler

A second example is:

{ .bbb
   (p8)	br.call rp = function-that-doesn't-return
	nop.b 0
	cover
}

The cover does affect the current frame state, as it allocates a NULL
register frame.  If you were to just decrement the ip, you'd pick up
the frame state for cover (in all likelihood).  Note that according to
Cary, the above example would be illegal because the frame state
changes between the point of br.call and the address that "rp" points
to.  But it shows that even without Cary's rule you'd could still get
into trouble with decrementing the IP.

Also, I'd like to point out that if X is a valid bundle address, then
X-1 is NOT a valid instruction address as it contains 0xf in the least
significant four bits.  I suspect that if you pass such an address to
an unwind library, you end up relying on implementation specific
behavior.

	--david

