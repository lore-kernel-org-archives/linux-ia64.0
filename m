From: Russ Anderson <rja@sgi.com>
Date: Thu, 18 Nov 2004 22:56:49 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200411182256.iAIMuoP4141101@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> The patch is not quite how I had envsioned it.  I'd thought that
> you were going to point ar.k3 at the physical base of the whole percpu
> area, not just at the data structure for the mca/init parts.

OK, I'll do that.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
