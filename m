From: Russ Anderson <rja@sgi.com>
Date: Tue, 26 Feb 2008 23:46:53 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <20080226234653.GA23088@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 26, 2008 at 03:45:40PM -0700, Alex Chiang wrote:
> 
> I looked through some SAL specs, and it turns out that
> SAL_PHYSICAL_ID_INFO was introduced in v3.2, but this tiger
> implements v3.1.
> 
> SAL *should* be returning -1 for unimplemented calls, but
> something is going fantastically wrong here. Bjorn pointed out
> that both r2 and b6 contain the IP. Maybe SAL isn't computing
> branches correctly or something?
> 
> So what to do to work around a broken SAL? Seems like a chicken
> and egg problem to me -- the only way to try and check if a call
> is implemented or not is to call it, and calling it hangs the
> machine... :(
> 
> Thoughts?

How about putting back some of the code that avoided the problem?

The previous code must have bailed out before getting to 
ia64_sal_physical_id_info().  Did it print out an error message,
such as "No logical to physical processor mapping " or 
"ia64_pal_logical_to_phys failed with"?   What does ia64_pal_logical_to_phys()
return on a tiger box?
 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
