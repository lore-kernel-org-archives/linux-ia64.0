From: Nick Piggin <npiggin@suse.de>
Date: Mon, 12 Oct 2009 03:36:21 +0000
Subject: Re: ticket spinlocks and sizeof(struct dentry)
Message-Id: <20091012033621.GB25882@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091009021251.GA4287@wotan.suse.de>
In-Reply-To: <20091009021251.GA4287@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 09, 2009 at 09:02:31AM -0700, Luck, Tony wrote:
> > Just to let you know you may have turned sizeof(struct dentry) into
> > something nasty with 64 bit spinlocks (like 200 bytes) which would
> > mean a significant number (~half?) of dentries will cover 3 cachelines
> > instead of 2.
> 
> Thanks for the heads-up ... Linus also pointed out this downside of
> the current implementation.  IA64 uses 128 byte cache lines ... so your
> calculation of how many we use for a dentry is off (we move from
> exactly 1.5 cache lines to 1.5625 cache lines).  But this sucks too
> because now the cache-line boundaries are scattered in different
> places in different dentry instances,

Well this is why a given random dentry will now be nearly 50% likely to
cover 3 cachelines. So a statistically, your cacheline footprint for
dentry structures (assuming no sharing between adjacent dentries) has
increased from 2 lines per dentry to nearly 2.5.


> so all your careful work to
> put stuff that is used together into the same cache line is randomly
> broken on some dentry instances.

Well yes but I would say the way we pad the dentry is not very flexible
and prone to breakage like this. If we did something like:

struct dentry {
  union {
    struct {
      /* real dentry fields here */
      unsigned char d_iname[];
    };
    char ___pad[192];
  };
};

#define D_INLINE_NAME_LEN (192 - offsetof(d_iname))

Then it would be more flexible. OTOH maybe it is a bad thing if it
is resized without anybody noticing. We could instead leave it as
it is and have a cpp compile time warning if the size if not 192.

 
> > If I'm nost mistaken, this would probably be worth correcting.
> 
> I'm working on it.

Thanks
