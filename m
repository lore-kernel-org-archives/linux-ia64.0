From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 23 Jun 2004 19:49:04 +0000
Subject: RFT: IA-32 partial page patch
Message-Id: <40D9DEB0.6070703@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Those of you who were running into memory leaks with 32 bit programs on ia64, please try testing the latest tree from David or Linus. This patch, based on the discussion among a number of contributors on this list over the years, should take care of most outstanding issues.

More description is in the changelog. Gordon Jin <gordon.jin @ intel.com> is the primary author of the patch.

	-Arun

