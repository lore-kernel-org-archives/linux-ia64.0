From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Fri, 18 Mar 2005 02:06:45 +0000
Subject: Re: [PATCH] Prezeroing V8 + free_hot_zeroed_page + free_cold_zeroed page
Message-Id: <20050318020645.GC156968@dragonfly.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503171340480.9678@schroedinger.engr.sgi.com> <20050317140831.414b73bb.akpm@osdl.org> <Pine.LNX.4.58.0503171459310.10205@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503171459310.10205@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, holt@sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, Mar 17, 2005 at 05:36:50PM -0800, Christoph Lameter wrote:
> +        while (avenrun[0] >= ((unsigned long)sysctl_scrub_load << FSHIFT)) {
> +		set_current_state(TASK_UNINTERRUPTIBLE);
> +		schedule_timeout(30*HZ);
> +	}

This should probably be TASK_INTERRUPTIBLE.  It'll never actually get
interrupted either way since kernel threads block all signals, but
sleeping uninterruptibly contributes to the load average.  
