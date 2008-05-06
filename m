From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 May 2008 21:54:17 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC0147BDE8@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   1185         br.cond.sptk.many .work_processed_kernel        // re-check
>   1186 
>   1187 .notify:
>   1188 (pUStk) br.call.spnt.many rp=notify_resume_user
>
> on line 1188 we call notify_resume_user() with interrupts disabled (at
> least if we fall through from the code above ... I didn't check the
> state of interrupts if we branch to ".notify").

Oops ... that's a br.cond on 1185 (not a br.call) ... so there is
no fall through to .notify.  So we do have to trace backwards and
check on the state of interrupts for the places that branch to the
.notify label ... someone is doing so with interrupts masked.

-Tony
