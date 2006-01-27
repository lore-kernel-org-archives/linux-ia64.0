From: dann frazier <dannf@hp.com>
Date: Fri, 27 Jan 2006 23:24:15 +0000
Subject: Re: salinfo incorrectly returning -ENOMEM
Message-Id: <1138404255.19287.26.camel@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <1138400466.19287.24.camel@krebs.dannf>
In-Reply-To: <1138400466.19287.24.camel@krebs.dannf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-01-27 at 17:45 -0500, Prarit Bhargava wrote:
> dann frazier wrote:
> > salinfo_decode will silently exit occasionally due to a failed open
> > of /proc/sal/XXX/data.  This is because the kernel is returning -ENOMEM
> > after attempting to vmalloc a buffer of size  
> > ia64_sal_get_state_info_size(data->type).
> > 
> > However, on my system ia64_sal_get_state_info_size is returning 0, in
> > which case I'd think a NULL vmalloc() result is correct.  
> > 
> > This patch assumes, of course, that 0 is a reasonable return value from
> > ia64_sal_get_state_info_size().
> > 
> 
> I'm working on fixing this up ...
> 
> The issue here is that ia64_sal_get_state_info_size is not doing any 
> test on ia64_sal_retval.status other than to return 0.  0 is a 
> reasonable return on an error, but :) as you noted the caller better be 
> watching for it.
> 
> Dann, this patch will at least tell you what that return value is and 
> might a) indicate a bigger bug, or b) indicate what's wrong with your 
> platform ;).

Thanks Prarit.  Here's the output I get:

ia64_sal_get_state_info failed: Call completed with error
ia64_sal_get_state_info failed: Call completed with error

Useful, eh? :)


