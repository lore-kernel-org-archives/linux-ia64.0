From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 05 Aug 2003 22:43:28 +0000
Subject: Re: PATCH: gcc 3.3 support and quota workaround
Message-Id: <marc-linux-ia64-106012356213861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105897942901816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105897942901816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 23 July 2003 10:56 am, H. J. Lu wrote:
> I am using gcc 3.3 to build the ia64 2.4 kernel from
> 
> http://lia64.bkbits.net/linux-ia64-2.4
> 
> Gcc 3.3 doesn't like multi-line asm statement. I am enclosing a patch
> here.

In 2.6, the asm statement was moved into a .S file.  I'd rather see a
2.4 patch that does the same thing.

Also, gcc 3.3.1 was unable to build a stable kernel when I released
the 2.4.21 ia64 patch.  So use it at your own risk.

> Also the kernel won't compile with
> 
> CONFIG_QUOTA=y
> 
> in .config since INIT_QUOTA_MODULE_NAMES is not defined anywhere. I
> looked at fs/dquot.c. There are some codes which weren't in 2.4.22-pre6
> nor 2.4.22-pre7. Where did they come from? I use the patch enclosed to
> get the kernel to compile.

The patch that added INIT_QUOTA_MODULE_NAMES appears to have
been removed, so I think this problem no longer exists.  (I was
able to build a kernel with CONFIG_QUOTA=y.)

Bjorn

