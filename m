From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Jan 2005 23:50:42 +0000
Subject: RE: syscall exit path optimization
Message-Id: <16889.32338.355622.505299@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
In-Reply-To: <200501262102.j0QL2Qg28166@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Jan 2005 15:44:42 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> David Mosberger wrote on Wednesday, January 26, 2005 1:31 PM
  >> Couldn't you restore r8/r10 after .work_pending is done in if
  >> pLvSys is TRUE?  That way, .work_processed would simply preserve
  >> (save _and_ restore) r8/r10.

  Ken> Thank you for reviewing and the suggestion.  Here is the
  Ken> updated patch, net saving for 6 cycles compares to 4 with
  Ken> earlier version.

Tidy _and_ faster---not bad at all for a net change of one extra line!

Good work.

	--david
