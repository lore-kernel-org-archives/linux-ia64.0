From: Russ Anderson <rja@sgi.com>
Date: Tue, 03 Aug 2004 21:08:09 +0000
Subject: Re: Multiple Processors on OS_MCA
Message-Id: <200408032108.i73L892r004565@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E7B150F@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >2.6.7 kernel/mca_asm.S serializes processors at the entry and exit of
> >the OS_MCA with a spinloop, hence makes sure only one 
> >processor performs the OS_MCA at a time.
> >A processor toggles the spinloop var before exiting OS_MCA so that
> >another processor spinning on the entry can proceed to OS_MCA.
> 
> That wasn't intended to be a final solution ... just a temporary fix
> to make sure that two processors couldn't enter the kernel at the
> same time (which would lead to chaos in the current implementation
> because we only have one block of memory declared to save registers,
> use a stack etc.).

Is there a plan for the next step towards the final solution?

For example, would it make sense to have per CPU register & stack
save areas (etc) to handle multiple OS_MCAs concurrently?

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
