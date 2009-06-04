From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 04 Jun 2009 20:22:12 +0000
Subject: Re: [PATCH 2/6] headers_check fix: ia64, fpswa.h
Message-Id: <20090604202212.GD13892@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1244118232.5172.26.camel@ht.satnam> <1244118476.5172.29.camel@ht.satnam> <1244118599.5172.31.camel@ht.satnam>
In-Reply-To: <1244118599.5172.31.camel@ht.satnam>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaswinder Singh Rajput <jaswinder@kernel.org>, Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Thu, Jun 04, 2009 at 05:59:59PM +0530, Jaswinder Singh Rajput wrote:
> 
> fix the following 'make headers_check' warning:
> 
>   usr/include/asm-ia64/fpswa.h:71: extern's make no sense in userspace
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Tony - is this file really used from userspace.
Looking at the definitions I think not.

I not then the real fix is to unexport it.

	Sam
