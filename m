From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 20 Jul 2004 16:08:06 +0000
Subject: Re: fix for unkillable zombie task
Message-Id: <16637.17254.121371.640514@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16632.21429.257483.650452@napali.hpl.hp.com>
	<jesmbr3pfl.fsf@sykes.suse.de>
	<16636.7969.396569.877226@napali.hpl.hp.com>
	<jevfgjulx7.fsf@sykes.suse.de>
In-Reply-To: <jevfgjulx7.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Schwab <schwab@suse.de>
Cc: davidm@hpl.hp.com, torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Tue, 20 Jul 2004 10:23:32 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> David Mosberger <davidm@napali.hpl.hp.com> writes:
  >>>>>>> On Sat, 17 Jul 2004 12:20:46 +0200, Andreas Schwab
  >>>>>>> <schwab@suse.de> said:
  >>
  Andreas> Could this be the same problem as discussed in the thread
  Andreas> at
  Andreas> <http://marc.theaimsgroup.com/?t8857537300002&r=1&w=2>?

  >>  It appears the "final" patch never made it into Linus' tree?

  Andreas> And it appears to be a different issue, your patch doesn't
  Andreas> fix that.

Do you have a simple test-case?

	--david
