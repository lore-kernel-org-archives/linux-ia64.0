From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 11 Jan 2005 17:49:02 +0000
Subject: Re: [patch] Altix BTE error handling fix
Message-Id: <200501110949.03750.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
In-Reply-To: <200501102333.j0ANXJ4p068948@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, January 11, 2005 4:12 am, Robin Holt wrote:
> > I thought this went in months ago.  I guess I need to check on
> > where this change currently is.
>
> I/O Reorg patch blew this away.  Let's talk about the ieclr thing
> when you get I get into the office today and then resubmit.  This
> will be the third time we have submitted the spin_unlock() fix :(

Ugg.  That reorg really shouldn't have touched much beyond the I/O files, but 
for some reason it hit like everything in the tree.  I mistakenly assumed 
that it was just lindenting everything, which would have been fine 
(unfortunately, real changes mixed with lindent are pretty hard to pick up).  
Sorry about that, I'll keep a closer eye on things.

Jesse
