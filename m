From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 26 Jul 2002 15:38:26 +0000
Subject: Re: [Linux-ia64] [PATCH] arch/ia64/kernel/efi.c
Message-Id: <marc-linux-ia64-105590701905836@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905832@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905832@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Marvin wrote:
> I've enclosed a patch to fix the problem.  Since this is primarily a
> debugging option, this isn't a critical fix.

Performance folks use this to characterize system performance too.
They don't like to muck with HW any more than they have to.

We've used it in the past to work around platform issues - not just
to "debug" them. It becomes critical if we discover we need such
a workaround.

grant

