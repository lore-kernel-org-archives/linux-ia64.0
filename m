From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 May 2002 14:57:38 +0000
Subject: [Linux-ia64] Re: Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905612@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 May 2002 13:56:22 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi David, The files perfmon_itanium.h, perfmon_generic.h and
  Peter> perfmon_mckinley.h are missing from the bk archive. I believe
  Peter> they should have been added at: ChangeSet@1.552.24.3
  Peter> 2002-05-24 18:45:43-0700 eranian@hp.com

Note that the to-linus-2.5 tree is work-in-progress.  I'm not done
with 2.5.18.  Having said that, you can just copy perfmon_itanium.h
from the 2.4.18 tree.  perfmon_mckinley.h won't be available
publically until Intel releases the NDA for the relevant info (hopefully
will happen soon).

	--david

