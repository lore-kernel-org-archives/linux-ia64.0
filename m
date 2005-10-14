From: Greg KH <greg@kroah.com>
Date: Fri, 14 Oct 2005 21:30:38 +0000
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-Id: <20051014213038.GA7450@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com>
In-Reply-To: <20051014192225.GD14418@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com, Dave Hansen <haveblue@us.ibm.com>, Jack Steiner <steiner@americas.sgi.com>

On Fri, Oct 14, 2005 at 02:22:25PM -0500, Robin Holt wrote:
> +EXPORT_SYMBOL(get_one_pte_map);

EXPORT_SYMBOL_GPL() ?

thanks,

greg k-h
