From: Russ Anderson <rja@sgi.com>
Date: Thu, 10 Feb 2005 23:59:58 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <200502102359.j1ANxwAl23861823@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> But Russ's last report of running with effectively the same patch
> wasn't positive:
> 
> > The patch (below) helps in that they system gets through the
> > MCA code and back to the error injection app, but then
> > the system dies.
> 
> Russ: Any detail on why the system died?

No real additional information.  It still fails with the latest 
release-2.6.11 tree.  It sometimes recovers once or twice, but
not more than that.  Something is getting trashed or not restored
correctly.  At least it is easily reproduceable, which makes 
problems much easier to track down.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
