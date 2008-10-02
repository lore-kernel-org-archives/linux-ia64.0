From: Roland McGrath <roland@redhat.com>
Date: Thu, 02 Oct 2008 21:24:34 +0000
Subject: RE: [patch 2/4] ia64 use trace hook
Message-Id: <20081002212434.0814A154212@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080917082022.191956457@sli10-desk.sh.intel.com>
In-Reply-To: <20080917082022.191956457@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think this patch meets this requirement.  The 2.6.27 version of
> tracehook_report_syscall_entry() always returns 0 ... so the error
> code paths are untested.

I don't really follow the ia64 asm.  But looks OK to me, assuming that int
return values are sign-extended in the register (I think syscall functions
always return long instead).

It's true that there is no handy way to test that yet.


Thanks,
Roland
