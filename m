From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 29 Jun 2004 16:57:26 +0000
Subject: Re: [PATCH] update early printk for new console driver
Message-Id: <200406290957.26047.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406290946.32162.jbarnes@engr.sgi.com>
In-Reply-To: <200406290946.32162.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 9:46 am, Jesse Barnes wrote:
> The Altix console driver has been replaced in Andrew's tree by a new one
> that uses the serial core API.  Update the early_console_setup routine to
> use the new config option so that it's ready when the driver hits Linus'
> tree.  This will also fix a build bug since the old driver hasn't been
> updated.

Oops.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
