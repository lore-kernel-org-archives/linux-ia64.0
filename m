From: "Ken Chen" <kenchen@google.com>
Date: Tue, 06 Feb 2007 22:02:43 +0000
Subject: Re: [PATCH] Hook up getcpu system call for IA64
Message-Id: <b040c32a0702061402j7233ac83yb33f1e2c5d945577@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Could you please explain why fsys call? Sys_getcpu takes about 600cycles
> on 1.6GHz Montecito. Do we need to save these cycles?

Andi Kleen used to lecture me every so often why it is important to
have fast vgetcpu on x86-64 (I don't think ia64 is excluded from
that).  His lecture is also all over the lkml mailing list.
