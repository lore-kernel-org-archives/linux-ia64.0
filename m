From: Robin Holt <holt@sgi.com>
Date: Mon, 14 Mar 2005 17:27:33 +0000
Subject: How should I proceed with page table caches?
Message-Id: <20050314172733.GA11272@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony and David,

Is there any chance I can do another push of the page table cache stuff
with the last bits of cleanup and those getting in without addressing
the removal of the cpu_idle() call?  Neither solution I was given last
week seems particularly well fitted to the problem at hand.  I would
like to get this in so I can continue working on the 4-level page table
directory I am really trying to address.

Thanks,
Robin Holt
