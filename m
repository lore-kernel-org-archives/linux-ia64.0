From: Nish Aravamudan <nish.aravamudan@gmail.com>
Date: Fri, 18 Mar 2005 05:43:17 +0000
Subject: Re: [PATCH] Prezeroing V8 + free_hot_zeroed_page + free_cold_zeroed page
Message-Id: <29495f1d050317214315f6da3d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503171340480.9678@schroedinger.engr.sgi.com>
	 <20050317140831.414b73bb.akpm@osdl.org>
	 <Pine.LNX.4.58.0503171459310.10205@schroedinger.engr.sgi.com>
	 <20050318020645.GC156968@dragonfly.engr.sgi.com>
	 <Pine.LNX.4.58.0503171808540.11258@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503171808540.11258@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Jason Uhlenkott <jasonuhl@sgi.com>, Andrew Morton <akpm@osdl.org>, holt@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 17 Mar 2005 18:09:11 -0800 (PST), Christoph Lameter
<clameter@sgi.com> wrote:
> On Thu, 17 Mar 2005, Jason Uhlenkott wrote:
> 
> > On Thu, Mar 17, 2005 at 05:36:50PM -0800, Christoph Lameter wrote:
> > > +        while (avenrun[0] >= ((unsigned long)sysctl_scrub_load << FSHIFT)) {
> > > +           set_current_state(TASK_UNINTERRUPTIBLE);
> > > +           schedule_timeout(30*HZ);
> > > +   }
> >
> > This should probably be TASK_INTERRUPTIBLE.  It'll never actually get
> > interrupted either way since kernel threads block all signals, but
> > sleeping uninterruptibly contributes to the load average.
> 
> Correct. .... I just do not seem to be able to get this right.

I think msleep_interruptible(30000) would be your best choice, then. 
Maybe with a comment that you don't actually expect signals, but are
using TASK_INTERRUPTIBLE to avoid contributing to load average (that
way, if the loadavg calculation changes someday, somebody will be able
to change your sleep over appropriately).

Thanks,
Nish
