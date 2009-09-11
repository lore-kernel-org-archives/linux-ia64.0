From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 11 Sep 2009 16:47:49 +0000
Subject: Re: [RFC] Convert ia64 spinlocks to use "tickets"
Message-Id: <4AAA7F35.5030403@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4aa9e16649286264@agluck-desktop.sc.intel.com>
In-Reply-To: <4aa9e16649286264@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Early last year x86 changed their spinlock implementation to
> use a fair "ticket" system (just like the one at deli counter
> in the grocery store).  Here is the same conversion for ia64.

A naieve comment, but doesn't a desire to implement "fairness" suggest lock 
contention that aught to be addressed?

rick jones
