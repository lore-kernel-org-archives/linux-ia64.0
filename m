From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 22 Feb 2005 17:52:25 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <20050222175225.GK28741@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net> <20050222020309.4289504c.akpm@osdl.org> <yq0ekf8lksf.fsf@jaguar.mkp.net>
In-Reply-To: <yq0ekf8lksf.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@wildopensource.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 22, 2005 at 09:41:04AM -0500, Jes Sorensen wrote:
> >> + if (page->flags & PG_uncached)
> 
> Andrew> dude.  That ain't gonna work ;)
> 
> Pardon my lack of clue, but why not?

I think you're supposed to always use test_bit() to check page flags

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
