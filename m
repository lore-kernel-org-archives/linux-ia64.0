From: Erich Focht <efocht@ess.nec.de>
Date: Fri, 19 Jul 2002 17:11:48 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905788@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ingo,

On Saturday 20 July 2002 18:57, Ingo Molnar wrote:
> On Fri, 19 Jul 2002, Erich Focht wrote:
> > The attached patch fixes problems with the "complex" macros in the
> > scheduler, as discussed about a week ago with Ingo on this mailing list.
>
> the fix has been in my tree for some time, the latest version, against
> 2.5.26 is at:
>
>   http://people.redhat.com/mingo/O(1)-scheduler/sched-2.5.26-B7
>
> it has a number of other fixes as well, plus the SCHED_BATCH feature.
>
> 	Ingo

Thanks. But as long as SCHED_BATCH ins't in 2.5.X, we need this separate
fix. And if it's in the main tree, you don't need it additionally in
your patches. The fix is O(1) specific and I thought it should not hide
inside the SCHED_BATCH patches, some people might encounter these
problems...

Regards,
Erich


