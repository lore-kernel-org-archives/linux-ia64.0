From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 28 Feb 2008 18:13:43 +0000
Subject: Re: 2.6.25-rc2-mm1 - boot hangs on ia64
Message-Id: <20080228101343.1b9548e6.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080227103831.423F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080227071118.GA4638@elte.hu>
	<20080228192509.BDCF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080228115041.GA22082@elte.hu>
In-Reply-To: <20080228115041.GA22082@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Steven Rostedt <srostedt@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-ia64 <linux-ia64@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, Bob Picco <bob.picco@hp.com>, Eric Whitney <eric.whitney@hp.com>

On Thu, 28 Feb 2008 12:50:41 +0100 Ingo Molnar <mingo@elte.hu> wrote:

> @@ -1000,7 +1001,7 @@ void release_console_sem(void)
>  	 * If we try to wake up klogd while printing with the runqueue lock
>  	 * held, this will deadlock.
>  	 */
> -	if (wake_klogd && !runqueue_is_locked())
> +	if (wake_klogd)
>  		wake_up_klogd();
>  }

I don't think we shoudl have added that hack in the first place.  It solves a
problem which about three developers hit four times in five years but it
has made kernel logging less reliable for everyone.

