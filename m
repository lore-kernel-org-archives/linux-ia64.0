From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 13 May 2004 15:52:33 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405130852.33182.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, May 13, 2004 2:02 am, Luck, Tony wrote:
> >There are also locking problems, since at the moment an MCA
> >could occur on multiple processors, but I think the MCA code
> >in general doesn't handle that case...
>
> At the moment the MCA code serializes simulaneous MCA on multiple
> processors (see the hand-crafted spinlock in mca_asm.S at the
> ia64_os_mca_spin label).

Thanks Tony, I hadn't looked at that code in awhile.  I guess the I/O error 
recovery code should try to acquire the io_range_list_lock before looking 
through the list.  If it can't get the lock, we just have to give up and make 
the error unrecoverable since we don't know if another CPU will take an MCA 
while holding that lock, leaving the list in a bad state...

I don't *think* that doing unconditional rendezvous in the PROM will help this 
situation either, but maybe someone else has good ideas about how to handle 
that?

Thanks,
Jesse
