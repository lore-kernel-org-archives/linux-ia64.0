From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sun, 19 Feb 2012 22:56:47 +0000
Subject: Re: [PATCH v2] arch/ia64: remove references to cpu_*_map.
Message-Id: <87sji68mu8.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4F3B8EAE.4050809@linux.vnet.ibm.com> <20120215130240.7308f373.akpm@linux-foundation.org> <87k43nbsli.fsf@rustcorp.com.au> <20120215183204.7928884a.akpm@linux-foundation.org>
In-Reply-To: <20120215183204.7928884a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Gortmaker <paul.gortmaker@windriver.com>, Gilad Ben-Yossef <gilad@benyossef.com>

On Wed, 15 Feb 2012 18:32:04 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> This stuff probably isn't all in linux-next yet.  I tried to get an
> update going today but failed.  I'll try again tomorrow, but it depends
> on how many additional oopses and build breakages our team of top-notch
> engineers chooses to add overnight.

Ah.  OK, please apply as many as you can; except for the ia64 stuff,
they're cleanup.  After next merge window I'll do another sweep to catch
any dregs.

Thanks,
Rusty.
