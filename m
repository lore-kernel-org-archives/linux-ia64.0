From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 05 Apr 2004 21:12:15 +0000
Subject: Re: Missing overflow check in mmap
Message-Id: <16497.52143.436055.254742@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jek70u74k6.fsf@sykes.suse.de>
In-Reply-To: <jek70u74k6.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 05 Apr 2004 18:49:45 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> Calling mmap with len = -1 was silently accepted.

Looks like the generic code was fixed last July, but the fix never
made it into the ia64-specific check.

Thanks for the patch,

	--david

