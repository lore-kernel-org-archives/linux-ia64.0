From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 07 Sep 2006 17:03:27 +0000
Subject: Re: [Fastboot] [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <20060907170327.GA5954@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
In-Reply-To: <82C6D21B8B7A9Cindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 07, 2006 at 06:44:30PM +0200, Andreas Schwab wrote:
> 0 is modified by the result of the GOT relocation for __gp
The 0 is the already modified value.

> __gp has no special meaning for gcc.  It's just another global variable.

Precisely the problem.  On ia64 gcc likes to compute the address
of global variables as offsets from __gp ... which it knows is
always available in r1.  So __gp gets no special treatment at all,
gcc knows that __gp = GOT + offset (and for __gp "offset" is 0).

-Tony
