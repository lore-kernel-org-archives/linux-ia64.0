From: Al Viro <viro@ftp.linux.org.uk>
Date: Fri, 27 Jul 2007 01:18:13 +0000
Subject: Re: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <20070727011813.GQ27237@ftp.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726210141.GA7266@uranus.ravnborg.org>
In-Reply-To: <20070726210141.GA7266@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sam Ravnborg <sam@ravnborg.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, Jul 26, 2007 at 11:01:41PM +0200, Sam Ravnborg wrote:
  
> +static void *__init_refok alloc_rte(unsigned long size)
> +{
> +	return alloc_bootmem(size);
> +}

That makes no sense at all.  If we ever call that after freeing initmem,
we are screwed, period.  Sounds like __init fodder.
