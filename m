From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 01:13:44 +0000
Subject: Re: [Linux-ia64] Long format VHPT and TLB sharing patches
Message-Id: <marc-linux-ia64-105590723706097@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706052@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706052@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 12:37:32 +1000, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> As part of research we did at UNSW, we implemented the long
  Matt> format VHPT as well as some experimental features to improve
  Matt> TLB coverage (sharing of RIDs for text regions, and a global
  Matt> shared mmap region with protection keys for protection).  We
  Matt> are now making these patches available.

  Matt> The long format VHPT patch should be fairly stable.  It could
  Matt> be used as a basis for future work on superpages etc.

It's good to see this!  I haven't had a chance to review it closely,
but it's definitely an area that should be interesting to experiment
with.

My preference would be to maintain this as a separate patch for now.
Once 2.7 opens up, we can consider it for the main tree (at least if
superpage work picks up and suggests that it's overall the better way
to go or if there is some other killer application for long format).

	--david

