From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Feb 2005 00:54:45 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <16906.45269.60406.579140@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Feb 2005 16:44:44 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> It just went bang, saying that "f6" was corrupted ... but I'm not
  >> doing the right things to tickle the corner case on a regular
  >> basis ... so I only have the one data point so far.

  Tony> Hmmm ... I'm not seeing anyplace where f6 is saved in the MCA
  Tony> path before we call up to ia64_mca_ucmc_handler() ... which is
  Tony> bad as f6 is designated as a scratch register.

That certainly would do the trick.

Am I seeing this right: the path doesn't save practically nothing
other than what is saved in the PAL min-state area?  The path
presumably also ought to switch the register-backing store (I think
Keith alluded to this previously).

	--david
