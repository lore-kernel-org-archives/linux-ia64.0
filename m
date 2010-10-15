From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 15 Oct 2010 14:08:19 +0000
Subject: Re: [PATCH 6/7] drivers/serial/ioc3_serial.c: Return -ENOMEM on
Message-Id: <20101015140819.GA3163@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1287147610-8041-6-git-send-email-julia@diku.dk>
In-Reply-To: <1287147610-8041-6-git-send-email-julia@diku.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <julia@diku.dk>
Cc: Pat Gefre <pfg@sgi.com>, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org

On Fri, Oct 15, 2010 at 03:00:09PM +0200, Julia Lawall wrote:

> From: Julia Lawall <julia@diku.dk>
> 
> In this code, 0 is returned on memory allocation failure, even though other
> failures return -ENOMEM or other similar values.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)

Dunno why linux-mips rsp. myself keep receiving patches for the ioc3 serial
driver - it's only being used on SGI IA64 machines.

Either way, I'm willing to funnel this patch upstream - I'm building a
pull rq for tonight anyway.

  Ralf
