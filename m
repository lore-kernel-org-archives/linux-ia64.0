From: Ray Bryant <raybry@engr.sgi.com>
Date: Fri, 15 Feb 2002 15:47:08 +0000
Subject: Re: [Linux-ia64] size of spinlock_t
Message-Id: <marc-linux-ia64-105590701905110@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes that was it.  Thanks.  I am totally amazed that "make clean; make
vmlinux" did not remake offsets.h.

David Mosberger wrote:
> 
> >>>>> On Fri, 15 Feb 2002 00:14:55 -0600, Ray Bryant <raybry@engr.sgi.com> said:
> 
>   Ray> In experimenting with new numa lock implementation, I changed
>   Ray> the size of spinlock_t to 16 bytes.  The resulting kernel hangs
>   Ray> on our SN hardware just after printing "All processors have
>   Ray> done init_idle".  Now it is possible this is something peculiar
>   Ray> to the SGI kernels, but I was wondering if anyone knew of
>   Ray> places in the IA64 kernel that "know" that
>   Ray> sizeof(spinlock_t)=8 and don't work correctly if this is
>   Ray> changed.
> 
> Are you sure it's not just include/asm/offsets.h that's out of date?
> Make sure you have no stray arch/ia64/tools/print_offsets.s file and
> then rerun make dep.
> 
>         --david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant               SGI
512-453-9679 (work)      512-507-7807 (cell)
raybry@sgi.com           raybry@austin.rr.com
     Computers are like air conditioners.
   They stop working when you open Windows.
-----------------------------------------------

