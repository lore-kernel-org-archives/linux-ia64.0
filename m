From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 18 Oct 2001 00:47:48 +0000
Subject: Re: [Linux-ia64] [patch] ia64-011010 die() deadlock
Message-Id: <marc-linux-ia64-105590698805365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805346@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805346@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Oct 2001 12:46:45 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Any die() routine that uses die_lock to avoid multiple cpu
  Keith> reentrancy will deadlock on recursive die() errors.  This
  Keith> patch fixes ia64-011010.  Andrew Morton, who did the original
  Keith> die_lock code, agrees that this is required.

  Keith> The code makes best effort at diagnosing the first recursive
  Keith> error then gives up.  This patch removes the only reference
  Keith> to IA64_KERNEL_DEATH so I deleted the flag as well.

Works for me.  Patch applied.

Thanks,

	--david

