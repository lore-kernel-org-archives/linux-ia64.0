From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 22 Jul 2003 00:15:39 +0000
Subject: RE: [PATCH] don't use ld.bias
Message-Id: <marc-linux-ia64-105884323804844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883179830025@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883179830025@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Patch to fix spin_lock to not use ld.bias since it causes a bunch of
bus
> activity that hurts scalability when a lock is contended.

It's dangerous to say something without knowing the whole context, but I
can't resist asking why not fix the contended lock area instead?  Sounds
like you have some serious contention.
