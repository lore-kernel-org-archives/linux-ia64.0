From: Matthew Wilcox <willy@debian.org>
Date: Fri, 26 Jul 2002 14:13:22 +0000
Subject: Re: [Linux-ia64] [PATCH] arch/ia64/kernel/efi.c
Message-Id: <marc-linux-ia64-105590701905834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905832@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905832@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jul 26, 2002 at 03:50:03PM +0200, Andreas Schwab wrote:
> IMHO the current behaviour is still useful.  For example to make sure you
> have only memory below 4G you can say "mem=4G".

maybe it's useful, but it's not what the option is specified to do:

        mem=nn[KMG]     [KNL,BOOT] force use of a specific amount of
                        memory; to be used when the kernel is not able
                        to see the whole system memory or for test.

-- 
Revolutions do not require corporate support.

