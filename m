From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 30 Jun 2004 16:23:52 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <200406300923.52093.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 5:04 pm, David Mosberger wrote:
> <jbarnes@engr.sgi.com> (04/06/29 1.1807)
>    [PATCH] ia64: update early printk for new console driver

Btw, with this new early console setup stuff, CONFIG_IA64_EARLY_PRINTK is 
obsolete.  If we tie in the other early consoles, we can probably drop that 
part of the ia64 patch altogether.

Jesse
