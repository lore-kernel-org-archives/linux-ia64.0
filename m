From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 Jan 2004 18:01:55 +0000
Subject: RE: Link error with linux-2.5 bk
Message-Id: <16398.48787.367528.610016@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Jan 2004 09:57:43 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> Andrew sent me the attached.  He seems to agree with your analysis & fix.

  Tony> Why didn't this show up on other architecture builds?  Doesn't
  Tony> anyone else discard .exit.text?  Or does everyone else have
  Tony> the default for CONFIG_DUMMY set to 'n' or 'm' rather than
  Tony> 'y'?

I'm wondering about that, too.

  Tony> I'd also like to nominate:

  Tony> local symbol 0: discarded in section `.exit.text' from drivers/built-in.o

  Tony> for the "Least helpful error message" award(*).  From previous
  Tony> experience I know that this is caused by improper use of
  Tony> __exit ... but it would really help a lot if the message had
  Tony> an actual symbol name, rather than "local symbol 0".

I think the linker has even worse error messages.  Perhaps you could
talk HJ into taking a look at it?  (In his copious spare time...)

	--david
