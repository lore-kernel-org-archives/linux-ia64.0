From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 03 Jul 2002 16:38:49 +0000
Subject: [Linux-ia64] RE: kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905733@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

>>>>> On Wed, 3 Jul 2002 09:33:35 -0700 , "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Xavier, Wondering if you can extract the test cases out of your
  Ken> test suite and send to me?  The first one is intended not to
  Ken> expand the exception marcro due to instruction bundling issue.

Note that with gcc3, tags instead of labels are used to delineate
exception regions.  Thus, you shouldn't have to worry about bundling
any longer.

	--david

