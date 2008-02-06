From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 06 Feb 2008 17:37:54 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843EC8485EC@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Any reason the various ptrace bits are not included in this pull?

The ptrace bits depend upon some generic changes to add arch_ptrace_stop()
... I think Andrew included them as part 89/260 of today's early
morning mail patch bomb.

-Tony

