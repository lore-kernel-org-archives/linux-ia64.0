From: "Jan Beulich" <JBeulich@novell.com>
Date: Thu, 03 Feb 2005 08:12:37 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <s201dcdd.091@emea1-mh.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

That is correct. However, to comply with this *AND* emit an error when a
symbol mentioned with .proc wasn't defined before the .endp, more
substantial changes to the assembler would be necessary (it would have
to keep track of all the symbols mentioned in .proc, which it currently
doesn't). I can certainly do such a change, but I think ignoring the
name arguments of .endp is a bad idea. Jan

>>> davidm@napali.hpl.hp.com 02.02.05 23:50:45 >>>
[Hi Jan, I sent this to HJ, assuming that he changed the assembler,
 but looking through the ChangeLog, I now believe that you added the
 .endp checking.  I see you also added some unwind-directive sanity
 checking and other useful improvements, which should be very
helpful.]

>>>>> On Wed, 2 Feb 2005 14:19:18 -0800, "H. J. Lu" <hjl@lucon.org>
said:

  HJ> The new ia64 assembler caught a few directive bugs.

  HJ> -END(idirty_bit)
  HJ> +END(dirty_bit)

While I'm in favor of fixing such typos, the Itanium Assembly Language
Reference Manual states:

	"The assembler ignores the name operands of the
	 directive."

(page 35 of document 248801-004).

In my opinion, a warning might be in place, but a hard error for
something that the spec explicitly allows seems like a bad idea to me.

	--david
