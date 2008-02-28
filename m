From: Roland McGrath <roland@redhat.com>
Date: Thu, 28 Feb 2008 21:10:47 +0000
Subject: Re: [PATCH] core dump: user_regset writeback
Message-Id: <20080228211047.AFDF92700FD@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080227200638.15D092700FD@magilla.localdomain>
	<20080228124522.3ae08f19.akpm@linux-foundation.org>
In-Reply-To: Andrew Morton's message of  Thursday, 28 February 2008 12:45:22 -0800 <20080228124522.3ae08f19.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, shaohua.li@intel.com, linux-ia64@vger.kernel.org

> Is there a need for this in 2.6.25?

It is a prerequisite for ia64 to switch on CORE_DUMP_USE_REGSET.  (It's
also a very low-impact patch easy to convince oneself does nothing on other
machines, and it's in new 2.6.25 code so far used only on x86, powerpc, and
sparc.)  I think those patches are on their way to being merged by ia64
maintainers.  But I don't know what their targets are.  I'm guessing not
til after .25.  Shaohua Li is driving that effort.


Thanks,
Roland
