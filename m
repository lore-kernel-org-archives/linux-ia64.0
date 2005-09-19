From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Mon, 19 Sep 2005 22:19:10 +0000
Subject: Re: [patch] MCA recovery verify pfn_valid
Message-Id: <200509192219.j8JMJAVB2758540@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
In-Reply-To: <200509162154.j8GLsrWN2681135@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack Steiner wrote:
> > On Fri, Sep 16, 2005 at 04:54:53PM -0500, Russ Anderson wrote:
> > 
> > Verify the pfn is valid before calling pfn_to_page().
> > 
> > Signed-off-by: Russ Anderson (rja@sgi.com)
> > 
> > ---------------------------------------------------------------------
> >  arch/ia64/kernel/mca_drv.c |    3 +++
> >  1 files changed, 3 insertions(+)
> > 
> > Index: linux-2.6.git#test/arch/ia64/kernel/mca_drv.c
> > =================================> > --- linux-2.6.git#test.orig/arch/ia64/kernel/mca_drv.c	2005-09-16 16:28:11.857773257 -0500
> > +++ linux-2.6.git#test/arch/ia64/kernel/mca_drv.c	2005-09-16 16:29:32.119181669 -0500
> > @@ -87,6 +87,9 @@ mca_page_isolate(unsigned long paddr)
> >  	if ( !ia64_phys_addr_valid(paddr) ) 
> >  		return ISOLATE_NG;
> >  
> > +	if ( !pfn_valid(paddr))
> > +		return ISOLATE_OK;
> 
> Should this be ISOLATE_OK or ISOLATE_NG? 
> 
> If the page is from another partition, the page has not been isolated? I realize
> that the return status is not used for anything but printing a message, but it
> seems misleading to print that isolation was successful when nothing was actually done.
> 
> Perhaps another status should be returned.

In this case, is any message really needed?  As you say, success is
is misleading because nothing was done.  Failure is not accurate
because it didn't fail.  So perhaps a third status that does not
print any page isolation message is the best solution.

For reference, the code:
----------------------------------------------------------
void
mca_handler_bh(unsigned long paddr)
{
        printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
                current->pid, current->comm);

        spin_lock(&mca_bh_lock);
        if (mca_page_isolate(paddr) = ISOLATE_OK) {
                printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
        } else {
                printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
        }
        spin_unlock(&mca_bh_lock);

        /* This process is about to be killed itself */
        do_exit(SIGKILL);
}


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
