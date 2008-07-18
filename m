From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 18 Jul 2008 02:17:32 +0000
Subject: Re: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <20080718021732.GD26892%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 17, 2008 at 07:21:37AM -0700, Jeremy Fitzhardinge wrote:
> Isaku Yamahata wrote:
> >I had explained about that.
> >I had considered that option. However my conclusion is not share 
> >he implementation because xen/ia64 timer interrupt isn't
> >paravirtualized with VCPUOP_xxx hypercall. But xen/ia64 emulates
> >ar.itm register. (ar.itm is interval time match register which triggers
> >interrupt when interval time counter becomes same value)
> >
> >Since timer interruption is virtualized differently on xen/ia64,
> >the different implementation is a natural consequence.
> 
> OK, that means the clockevent and clocksource part would be different.  
> But the runstate accounting should still be the same, no?

Unfortunately no. At first I had hoped so, but no.
Looking consider_steal_time() which implements ia64 steal time
accounting, I have no idea to share code cleanly with x86 steal time
accounting, do_stolen_accounting().

-- 
yamahata
