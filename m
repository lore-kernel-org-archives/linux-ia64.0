From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 25 Jun 2007 23:24:29 +0000
Subject: RE: intercept trap when running a 32bit binary
Message-Id: <617E1C2C70743745A92448908E030B2A01C208B5@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I am trying to run 32bit binary Half Life dedicated server from Valve.
>
> This is what happens (in a 32bit chroot or with 32bit libs installed:
>
> ./srcds_run: line 344: 13869 Segmentation fault      (core dumped)

Do any x86 binaries work on this system?

Are you using ia32-el, or using h/w to execute (run "/etc/init.d/ia32el status"
to check).

If some x86 binaries work, then you could copy over an x86 gdb to
help debug this issue.

-Tony         
