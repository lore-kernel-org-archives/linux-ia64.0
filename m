From: James E Wilson <wilson@specifixinc.com>
Date: Thu, 27 Jan 2005 21:56:36 +0000
Subject: anyone using Itanium B-step support?
Message-Id: <1106862995.18514.108.camel@aretha.corp.specifixinc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The kernel still has an ITANIUM_BSTEP_SPECIFIC configure option, as of
2.6.8.1, which enables use of the gcc -mb-step option.  As far as I
know, this is the only user of the gcc/gas B-step support.  I am
skeptical that this support still works, and suggest that it be removed,
so that I can remove the gcc/gas B-step support.

The reason why this comes up now is because gas has support to emit
warnings in cases where extra nops must be emitted to avoid B-step
errata.  This is enabled by default.  At the time, this was useful to
ensure backwards compatibility, but now all it does is confuse end users
who have no idea what an Itanium B-step processor is.  To fix this, I
need to add an option to enable it, which means I need to fix gcc to
pass the option to gas, and I also need to fix the kernel to add the
option to aflags when CONFIG_ITANIUM_BSTEP_SPECIFIC.

However, rather than add more ITANIUM_BSTEP_SPECIFIC support to the
kernel, I think it makes more sense to obsolete it and remove it.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com


