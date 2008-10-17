From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Oct 2008 20:15:29 +0000
Subject: RE: [PATCH] ia64: use generic compat_sys_ptrace
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3533459D5@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080901161918.GB16320@lst.de>
In-Reply-To: <20080901161918.GB16320@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Lots of overlap between your patch for this and
part 4 of Shaohua Li's utrace preparation patch
series:

http://marc.info/?l=linux-ia64&m2172423100433&w=2


I've taken Shaohua's patch.  We can work out later
whether any bits that you did got missed.


Your sys32_pipe and sys32_pause patches are now both
in my tree.

-Tony
