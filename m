From: Andrew Vasquez <andrew.vasquez@qlogic.com>
Date: Tue, 29 Jul 2008 01:55:25 +0000
Subject: Re: [Patch] ia64 build failure due to msleep not defined.
Message-Id: <20080729015525.GD35050@plap4-2.qlogic.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729015111.GI9663@sgi.com>
In-Reply-To: <20080729015111.GI9663@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 28 Jul 2008, Robin Holt wrote:

> qla_attr.c failes to compile because it is missing the definition
> of msleep.  Specifically include linux/delay.h fixes this compile failure.
> 
> Signed-off-by: Robin Holt <holt@sgi.com>

The following should hit linus' tree RSN:

	[GIT PATCH] first bug fixes for 2.6.27-rc1
	http://article.gmane.org/gmane.linux.scsi/43485

Sorry about the mess...
