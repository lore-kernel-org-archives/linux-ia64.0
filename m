From: Grant Grundler <iod00d@hp.com>
Date: Fri, 17 Oct 2003 18:42:00 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106641613500738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 01:12:07PM +0200, Andreas Schwab wrote:
> +EXPORT_SYMBOL(csum_partial);

yeah - the netfilter code needs this.
2.6.0-test7 plus csum_partial is running on my external box now.
I've uploaded tarball of vmlinuz+config+modules to
	ftp://gsyprf10.external.hp.com/kernels/ia64/2.6.0-test7.tgz

setserial crashes the box though. bjorn is looking into it.
(2.6.0-test5 returns EBUSY to setserial)
I've "apt-get remove setserial" since I don't need setserial.

hth,
grant
