From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 04 Jul 2003 03:52:48 +0000
Subject: Re: Early printk is Gone....???
Message-Id: <marc-linux-ia64-105729113832577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105711058824791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105711058824791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Hicks <mort@wildopensource.com> writes:


Martin> EARLY_PRINTK is really only for bringup.  It really don't
Martin> expect that it will ever be pushed to Linus.  The to-linus
Martin> tree is really only for David to stick changesets in for Linus
Martin> to pull into the mainline kernel.  It does not compile, and
Martin> doesn't have to.

I understand that; the issue I have is that CONFIG_EARLY_PRINTK is
defined in Kconfig, but does nothing, because the code is not there.

Peter c
