From: Russ Anderson <rja@sgi.com>
Date: Fri, 04 Mar 2005 18:55:55 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <200503041855.j24Ittk911207335@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> I've established that the scratch FP registers need to be saved, but
> nobody is doing that.
> 
> Attached (untested) patch does that (not paticularly elegantly, but
> should be functional).

When I try that patch, the system wedges in the MCA code (on Altix).


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
