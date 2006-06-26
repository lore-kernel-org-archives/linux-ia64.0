From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 26 Jun 2006 17:23:19 +0000
Subject: RE: patches added to release/test trees
Message-Id: <617E1C2C70743745A92448908E030B2A27EED0@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I linked his tags directory to my tree ... lets see how that works.
>
> I noticed (to my surprise) a bunch of tags show up while using gitweb 
> this morning. So I guess its working, at least to some extent.

The only bit that I'm worried about is what will happen when
Linus adds a new tag.  Until I do a pull&push to catch up, I'll
have a "bogus" tag (pointing to an object that I don't have).
Whether this is an annoyance, or a major problem, remains to
be seen.

The 2.6.17 tag is now 8 days old, so if Linus sticks to the 2-week
merge window, we'll find out in ~6days when 2.6.18-rc1 comes out.

-Tony
