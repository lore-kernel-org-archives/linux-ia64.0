From: Greg KH <greg@kroah.com>
Date: Fri, 13 May 2005 16:38:45 +0000
Subject: Re: [PATCH 4/6]: hotplug/ia64: SN Hotplug Driver - new SN PROM version code
Message-Id: <20050513163844.GF11089@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835E91.2080403@sgi.com>
In-Reply-To: <42835E91.2080403@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 12, 2005 at 08:45:58PM -0400, Prarit Bhargava wrote:
>  
> -	printk("SGI SAL version %x.%02x\n", major, minor);
> +	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);

No KERN_ level for this printk.  The kernel janitors will come after you
with pitchforks...



