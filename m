From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Oct 2003 23:51:09 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106565735509526@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Sep 2003 15:52:56 +1000, Nathan Scott <nathans@sgi.com> said:

  >>  Extending ino_t to 64 bits came up last October [1].  AFAIK,
  >> nobody bothered to investigate & send a patch, so things didn't
  >> change since then.

  >> --david

  >> [1] http://www.gelato.unsw.edu.au/linux-ia64/0210/3952.html


  Nathan> I notice a big batch of IA64 changes has just gone into
  Nathan> 2.6-test6, but this change seems to be missing.  Is it in
  Nathan> someones queue for next time or do I need to describe the
  Nathan> problem more clearly?

  Nathan> The investigation and the patch I sent are available
  Nathan> here[2].

  Nathan> cheers.

  Nathan> -- Nathan

  Nathan> [2] http://www.gelato.unsw.edu.au/linux-ia64/0309/6681.html

The mail you're referring to talks about getdents64() only.  What I
didn't see is an argument why this is the _only_ user visible
interface that might be affected.  Are there any other interfaces
(syscalls, /proc/whatever, etc.) that may directly or indirectly be
affected?  If not and if the change has been run through a reasonable
test-suite (LTP?) without ill effects, I'm certainly OK with the
change.

	--david

PS: It would help to get this resolved quickly, e.g., before test8.
