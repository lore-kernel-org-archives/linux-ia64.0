From: Greg Howard <ghoward@sgi.com>
Date: Thu, 10 Mar 2005 16:48:21 +0000
Subject: Re: [PATCH] Altix system controller event handling
Message-Id: <Pine.SGI.4.58.0503101046500.99607@gallifrey.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
In-Reply-To: <Pine.SGI.4.58.0503090818080.99386@gallifrey.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 10 Mar 2005, Andreas Schwab wrote:

>
> Or even better: replace scdrv_buffer_to_int by be32_to_cpup.

Sounds like a good idea.  Will be32_to_cpup work if the
argument isn't word-aligned?

Thanks - Greg

