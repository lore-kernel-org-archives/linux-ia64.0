From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 12 Feb 2001 23:17:02 +0000
Subject: Re: [Linux-ia64] ia64_get_dcr problem
Message-Id: <marc-linux-ia64-105590693005144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005143@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005143@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It is a kernel problem.  Your testcase can not work as intended without the
volatile in the definition of ia64_get_dcr.  It looks like the kernel doesn't
actually use ia64_get_dcr, which is why the problem wasn't noticed before.

Jim

