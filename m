From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Mar 2008 16:59:14 +0000
Subject: RE: [PATCH] New way of storing MCA/INIT logs
Message-Id: <1FE6DD409037234FAB833C420AA843ECBC39AE@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The probability to have more than that _independent_ events
> in a small time frame is very very low. Therefore you can
> afford losing events of the same "burst".

Both the CMC and CPE interrupt paths have code to switch to
polling mode in the presence of a burst of correctable errors.
Can we tune this threshold w.r.t. the number of buffers we
pre-allocate to save error records so that we (the OS) won't
be responsible for losing errors?  Obviously entering polling
mode puts the responsibility onto SAL to keep track of all
the error reports - but nobody ever complained that this
might result in the loss of error information if the SAL runs
out of space to keep the error records before the next poll
from the OS. ["solving" problems by shifting the blame point?]

-Tony
