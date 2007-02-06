From: "Ken Chen" <kenchen@google.com>
Date: Tue, 06 Feb 2007 21:21:46 +0000
Subject: Re: [PATCH] Hook up getcpu system call for IA64
Message-Id: <b040c32a0702061321y1ed7a10dgc9ee31dee408e574@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fenghua Yu wrote on Feb 5, 2007 4:07 PM
> getcpu system call returns cpu# and node# on which this system call
> and its caller are running. This patch hooks up its implementation on
> IA64.

I know it's trivial to wire up sys_getcpu, but please take this seriously,
it should be implemented as assembly fsys call.

- Ken
