From: Christoph Hellwig <hch@lst.de>
Date: Tue, 07 Oct 2003 08:09:09 +0000
Subject: Re: [PATCH] kill sn_ksyms.c
Message-Id: <marc-linux-ia64-106551418528596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106451999732538@msgid-missing>
In-Reply-To: <marc-linux-ia64-106451999732538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Oct 06, 2003 at 01:18:21PM -0500, Robin Holt wrote:
> I thought the sn_ksyms was already gone in 2.6.  I would say, go ahead
> and remove it.  We will include our EXPORT_SYMBOLs for the symbols
> we need at that time.
> 
> For 2.4, I guess I would say it isn't worth messing with.

All patches I send are for 2.6 only.  If you want them for 2.4 aswell
feel free to backport it, but I don't even look at 2.4 anymore these
days.

