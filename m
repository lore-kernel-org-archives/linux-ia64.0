From: Russ Anderson <rja@sgi.com>
Date: Wed, 04 May 2005 22:11:45 +0000
Subject: Re: catching up on the backlog
Message-Id: <200505042211.j44MBjvj1291229@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
In-Reply-To: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> I've picked through the list of patches in my backlog, and applied
> this bunch to my release tree ... before I ask Linus to pull, it
> would be useful to get some SGI testing (since the majority of the
> changes are SGI related).

The MCA recovery code runs on Altix with no noticeable regressions.
It was tested both integrated in the kernel and as a module.


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
