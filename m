From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 21:19:15 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16609.56531.992119.634369@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jun 2004 08:09:00 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  >> True, but I think there are only 3 call-sites.  If it turns out to be
  >> _really_ ugly we can reonsider, but I think it might be a better
  >> choice in the long run.


  Ken> How does this patch look?  It is a bit big. But what it does is really
  Ken> simple: change 3 call sites to save/restore virtual address of sp and
  Ken> ar.bsp/ar.bspstore.

Looks fine to me.

Thanks,

	--david
