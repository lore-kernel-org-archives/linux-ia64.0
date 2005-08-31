From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Wed, 31 Aug 2005 20:36:33 +0000
Subject: Re: Testing Keith's MCA/INIT patch (was RE: git pull on ia64 linux tree)
Message-Id: <200508312036.j7VKaX7O2330190@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F044726E4@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F044726E4@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> MCA testing is somewhat harder as it requires specialized h/w
> and/or s/w to inject the error.  But I know that some of you can
> do this ... so I'd like to hear what happens.

I've run the memory error injection code with Keith's patch
without any noticeable regression.  I vote to accept his
patch.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
