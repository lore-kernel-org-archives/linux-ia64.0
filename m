From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 23 Jul 2003 17:15:05 +0000
Subject: Re: PATCH: gcc 3.3 support and quota workaround
Message-Id: <marc-linux-ia64-105898051703312@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105897942901816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105897942901816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 23, 2003 at 09:56:34AM -0700, H. J. Lu wrote:
> Also the kernel won't compile with
> 
> CONFIG_QUOTA=y
> 
> in .config since INIT_QUOTA_MODULE_NAMES is not defined anywhere. I
> looked at fs/dquot.c. There are some codes which weren't in 2.4.22-pre6
> nor 2.4.22-pre7. Where did they come from? I use the patch enclosed to
> get the kernel to compile.

That was a bogus patch from Alan that was backed out again pretty soon.
I'd suggest pulling the latest updates from Marcelo into your tree.

