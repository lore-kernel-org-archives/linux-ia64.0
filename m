From: William Lee Irwin III <wli@holomorphy.com>
Date: Tue, 18 Oct 2005 23:28:24 +0000
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-Id: <20051018232824.GQ29402@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com> <20051014192225.GD14418@lnx-holt.americas.sgi.com> <20051014213038.GA7450@kroah.com> <20051017113131.GA30898@lnx-holt.americas.sgi.com>
In-Reply-To: <20051017113131.GA30898@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Greg KH <greg@kroah.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, Dave Hansen <haveblue@us.ibm.com>, Jack Steiner <steiner@americas.sgi.com>

On Mon, Oct 17, 2005 at 06:31:31AM -0500, Robin Holt wrote:
> Not sure why it would fall that way.  Looking at the directory,
> I get:
> [holt@lnx-holt mm]$ grep -c 'EXPORT_SYMBOL(' *.c | egrep -v ":0$"
[...]
> I will happily change it, but that seems inconsistent with the
> majority of the exports from that subsystem.

I'm a bit more laissez-faire on this: I don't mind the export either
way. That said, I'm aware that the prevailing opinion is in favor of
EXPORT_SYMBOL_GPL().


-- wli
