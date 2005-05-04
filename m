From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 04 May 2005 20:15:25 +0000
Subject: RE: [patch] speed up lfetch.fault [NULL] (take 2)
Message-Id: <200505042015.j44KFPg04287@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17016.57618.59637.485411@napali.hpl.hp.com>
In-Reply-To: <17016.57618.59637.485411@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Wednesday, May 04, 2005 7:50 AM
> This is a resend of the patch from March 26, with slight tweaking to
> omit the instruction needed to initialize p6.  Please apply to
> test-2.6.

David, the pr register need to be restored in the fast path ;-)
otherwise, p6 is clobbered.

- Ken

