From: Russ Anderson <rja@sgi.com>
Date: Wed, 25 Jun 2008 22:25:53 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v6
Message-Id: <20080625222553.GA29402@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080609162015.GD14939@sgi.com> <20080623121721.37CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080623121721.37CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

On Mon, Jun 23, 2008 at 12:25:40PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > +static ssize_t
> > +badpage_show(struct kobject *kobj,
> > +	     struct kobj_attribute *attr, char *buf)
> > +
> > +{
> > +	struct page *page, *page2;
> > +	int i = 0, cnt = 0;
> > +	char *bufend = buf + PAGE_SIZE;
> > +
> > +	cnt = snprintf(buf, bufend - (buf + cnt),
> > +			"Bad RAM: %d kB, %d pages marked bad\n"
> > +			"List of bad physical pages\n",
> > +			total_badpages << (PAGE_SHIFT - 10), total_badpages);
> > +
> > +	list_for_each_entry_safe(page, page2, &badpagelist, lru) {
> > +		if (bufend - (buf + cnt) < 20)
> > +			break;		/* Avoid overflowing the buffer */
> > +		cnt += snprintf(buf + cnt, bufend - (buf + cnt),
> > +				" 0x%011lx", page_to_phys(page));
> > +		if (!(++i % 5))
> > +			cnt += snprintf(buf + cnt, bufend - (buf + cnt), "\n");
> > +	}
> > +	cnt += snprintf(buf + cnt, bufend - (buf + cnt), "\n");
> > +
> > +	return cnt;
> > +}
> 
> it seems /proc/meminfo is better.
> because badpage is architecture independent concept.
> 
> nonsense?

The original patch used /proc/ (/proc/meminfo had badpage summary info
and /proc/badram had detailed info.  It was suggested that /sys was
a better place.

FWIW, I'm more than happy to put it anywhere deemed "best" by
the community.  It is currently /sys/kernel/badram.

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
