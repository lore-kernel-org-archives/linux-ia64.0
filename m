From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 17:52:35 +0000
Subject: RE: [patch] ia64: fix potential NaT bit error for sys_pipe().
Message-Id: <16879.61411.795077.162859@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.2168.388519.26567@napali.hpl.hp.com>
In-Reply-To: <16878.2168.388519.26567@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Please disregard the patch named in $SUBJECT.  It appears to be
breaking light-weight syscalls.  That's rather odd, but since Rohit
has some better ideas on how to fix this issue, I'd rather drop this
patch for the time being (the root problem is still there and IMHO,
needs to be fixed urgently).

	--david
