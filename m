From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 01 Aug 2002 04:01:32 +0000
Subject: RE: [Linux-ia64] [patch] Assign __gp to middle of short data sect
Message-Id: <marc-linux-ia64-105590701905871@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905870@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905870@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Keith Owens [mailto:kaos@ocs.com.au]

> I was getting '__gp does not cover short data segment'.
> arch/ia64/vmlinus.lds.S assigns __gp well away from the short data
> sections, for no good reason that I can see.  A kernel with more than
> 2^21 bytes between __gp and the end of sbss cannot link.
>
> This patch (against 2.4.18) puts __gp right in the middle of the short
> data sections.  The comment 'gp must be 16-byte aligned for exc. table'
> puzzles me, AFAICT the exception tables are not accessed via gp.

Look at include/asm-ia64/uaccess.h ... all the exception table entries
use gp relative addressing.

-Tony

