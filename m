From: dann frazier <dannf@hp.com>
Date: Wed, 08 Feb 2006 17:52:41 +0000
Subject: Re: salinfo incorrectly returning -ENOMEM
Message-Id: <1139421161.30996.93.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1138400466.19287.24.camel@krebs.dannf>
In-Reply-To: <1138400466.19287.24.camel@krebs.dannf>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 2006-01-28 at 11:07 +1100, Keith Owens wrote:
> dann frazier (on Fri, 27 Jan 2006 15:21:06 -0700) wrote:
> >salinfo_decode will silently exit occasionally due to a failed open
> >of /proc/sal/XXX/data.  This is because the kernel is returning -ENOMEM
> >after attempting to vmalloc a buffer of size  
> >ia64_sal_get_state_info_size(data->type).
> >
> >However, on my system ia64_sal_get_state_info_size is returning 0, in
> >which case I'd think a NULL vmalloc() result is correct.  
> >
> >This patch assumes, of course, that 0 is a reasonable return value from
> >ia64_sal_get_state_info_size().
> 
> Nak this patch.
> 
> Zero is not a valid return value from ia64_sal_get_state_info_size().
> That SAL call must return the maximum size for the record type so that
> the OS can preallocate the required buffers while the OS is in normal
> context.  The buffers cannot be allocated when the SAL interrupt occurs
> because vmalloc cannot be used in interrupt context.  If SAL is not
> returning a valid value from ia64_sal_get_state_info_size() then your
> version of SAL is wrong and the only thing that the OS can do is to
> give up on that record type.  

Just to follow-up - we've determined that is an issue with the version
of firmware some of our machines are running.  Thanks for everyone's
responses.


