From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 09 Dec 2004 23:22:32 +0000
Subject: RE: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <16824.56888.637382.591027@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 9 Dec 2004 15:19:07 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> I just think stashing away pids in the kernel is a slippery slope
  >> we do not want to get onto.

  >> Can't you stash away a reference to the task-structure and bump
  >> the reference count?

  Tony> Can we do that in MCA context (without getting any locks)?

I'd think you'd have to get the reference much earlier than that,
namely at the time you map the MMIO region.

	--david
