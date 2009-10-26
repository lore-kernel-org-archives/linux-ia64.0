From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 26 Oct 2009 23:36:53 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <12411.1256600213@ocs14w>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 26 Oct 2009 18:15:22 -0400, 
Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>As Intel manual says, it seems that pmsa_iip has a value of ip register
>where INIT interrupted when psr.ic is 0. Ok, I'll make a patch so that
>pmsa_iip is used irrespective of a value of psr.ic.
>
>Please let me know if I need to confirm something else before I make a
>patch.

That looks good.  The only problem I can think of is an MCA/INIT
arriving while code like SAVE_MIN or SAVE_REST is executing.  Back
tracing at that point using pmsa_iip is going to be a problem, you have
no idea what state the registers or stack are in.

