From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 17 Jul 2008 06:11:27 +0000
Subject: Re: [PATCH 24/29] ia64/pv_ops/xen: implement xen pv_time_ops.
Message-Id: <20080717061127.GF25137%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12162606623288-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12162606623288-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 16, 2008 at 10:45:16PM -0700, Jeremy Fitzhardinge wrote:
> Isaku Yamahata wrote:
> >implement xen pv_time_ops to account steal time.
> >  
> 
> I think you could just share arch/x86/xen/time.c, couldn't you?  I'd be 
> happy to accept a patch to move all the shareable bits into 
> drivers/xen/time.c.

I had explained about that.
I had considered that option. However my conclusion is not share 
he implementation because xen/ia64 timer interrupt isn't
paravirtualized with VCPUOP_xxx hypercall. But xen/ia64 emulates
ar.itm register. (ar.itm is interval time match register which triggers
interrupt when interval time counter becomes same value)

Since timer interruption is virtualized differently on xen/ia64,
the different implementation is a natural consequence.

thanks,
-- 
yamahata
