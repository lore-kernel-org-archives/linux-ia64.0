From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 19 Jul 2004 19:21:05 +0000
Subject: Re: fix for unkillable zombie task
Message-Id: <16636.7969.396569.877226@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16632.21429.257483.650452@napali.hpl.hp.com>
	<jesmbr3pfl.fsf@sykes.suse.de>
In-Reply-To: <jesmbr3pfl.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: davidm@hpl.hp.com, torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Sat, 17 Jul 2004 12:20:46 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> Could this be the same problem as discussed in the thread at
  Andreas> <http://marc.theaimsgroup.com/?t8857537300002&r=1&w=2>?

It appears the "final" patch never made it into Linus' tree?

In any case, I'm certain the fix I submitted is needed, but I wouldn't
claim I understand all of the exit path handling---it's become rather
complicated with the NPTL-changes.  For example, one thing I don't
understand in forget_original_parent() is that it traverses the
father->children list and then does the check:

		if (father = p->real_parent) {

AFAIK, if "p" in on the father->children list, that implies that
(p->real_parent = father).  I suspect a typo here and
"p->real_parent" should read "p->parent", but I'm sure whoever wrote
this code must have tested it, so it's probably more likely I'm
missing something.

	--david
