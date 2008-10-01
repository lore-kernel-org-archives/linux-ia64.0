From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Oct 2008 22:14:40 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <57C9024A16AD2D4C97DC78E552063EA352D48B68@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> In 2.6.27 the only new thing there is to test is /proc/pid/syscall.  The
> other testing you can do is verify that there are no regressions for using
> strace, gdb, etc.  The ptrace-tests suite (look around the same wiki) is a
> good place to start, and the gdb test suite.  (Just worry about regressions
> from 2.6.27-rc8 or earlier vanilla kernels, not the absolute failure rate.)

Thanks.

/proc/$pid/syscall is there and appears to have reasonable values (shells
waiting for child processes are in syscall 1126 (wait4), those waiting for
user input in call 1026 (read).  The arguments look ok too.

strace works

I'll dig around for more stuff.

-Tony
