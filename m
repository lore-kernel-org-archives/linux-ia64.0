From: Jes Sorensen <jes@sgi.com>
Date: Thu, 29 May 2008 11:49:59 +0000
Subject: Re: [PATCH] mmtimer: Push BKL down into the ioctl handler
Message-Id: <yq0r6bls520.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080522214244.457da3d7@core>
In-Reply-To: <20080522214244.457da3d7@core>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Alan" = Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

Alan> Switches to unlocked_ioctl read to remove ioctl BKL method. Fix
Alan> the unknown ioctl return. Probably a nice easy one to kill off
Alan> BKL usage entirely later

Alan> Signed-off-by: Alan Cox <alan@redhat.com>

Looks good to me, I should check whether we can't just kill the
lock_kernel() here - I suspect it shouldn't be an issue.

Acked-by: Jes Sorensen <jes@sgi.com>

Cheers,
Jes
