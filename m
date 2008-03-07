From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 07 Mar 2008 13:51:20 +0000
Subject: Re: [PATCH] ia64: fix getpid and set_tid_address fast system calls for pid namespaces
Message-Id: <20080307135120.GA29388@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <47D141C1.2030604@openvz.org>
In-Reply-To: <47D141C1.2030604@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 07, 2008 at 04:23:13PM +0300, Pavel Emelyanov wrote:
> @@ -34,6 +35,9 @@
>  	DEFINE(SIGFRAME_SIZE, sizeof (struct sigframe));
>  	DEFINE(UNW_FRAME_INFO_SIZE, sizeof (struct unw_frame_info));
>  
> +	BUILD_BUG_ON(sizeof(struct upid) != 32);
> +	DEFINE(IA64_UPID_SHIFT, 5);
> +
>  	BLANK();
>  
>  	DEFINE(TI_FLAGS, offsetof(struct thread_info, flags));

This might work better with ilog2().  Something like this perhaps?

	BUILD_BUG_ON(!is_power_of_2(sizeof(struct upid)))
	DEFINE(IA64_UPID_SHIFT, ilog2(sizeof(struct upid)))

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
