From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Feb 2005 18:14:19 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <16905.379.980920.572835@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Feb 2005 10:11:24 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  >> The patch (below) helps in that they system gets through the MCA
  >> code and back to the error injection app, but then the system
  >> dies.

  Tony> Russ: Any detail on why the system died?

I assume you already checked that I didn't introduce any other stupid
dereferencing bugs?  I'd do it myself, but I'm still catching up with
my email backlog...

	--david
