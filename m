From: john stultz <johnstul@us.ibm.com>
Date: Wed, 18 Feb 2004 22:24:48 +0000
Subject: Re: [PATCH] linux-2.6.3_ia64-cyclone_A2.patch
Message-Id: <1077143087.985.140.camel@cog.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077136393.985.111.camel@cog.beaverton.ibm.com>
In-Reply-To: <1077136393.985.111.camel@cog.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-02-18 at 14:03, David Mosberger wrote:
> >>>>> On Wed, 18 Feb 2004 13:49:44 -0800, john stultz <johnstul@us.ibm.com> said:
> 
>   John> Gah! Where is this trailing whitespace?
> 
> I already deleted the whitespace (my editor is showing it in bright
> red, so it's kind a hard to ignore ;-).
> 
>   John> I went through this patch specifically eliminating any I could
>   John> find. Perhaps my mail client is trying to irritate me.
> 
> The whitespace wasn't systematic, so i doubt it was the mailer.
> Any chance the mail contained an old patch?

No, I just checked what I sent you and its the right patch. Using vi
"set list", I still don't see any within the context of the patch,
although I notice my message had trailing whitespace.


>   John> The code, while similar, isn't quite shareable w/
>   John> ia32. However, I'd be up for moving it to a separate IBM
>   John> directory if you'd prefer, although for just a single file it
>   John> seems like overkill.
> 
> I don't feel very strongly about it.  If you expect there to be other
> IBM-platform specific files in the future, it would make sense to
> create an ibm subdirectory.  It's really your call.

I don't believe there are any current plans that would call for new IBM
platform specific files. So I prefer the patch as it was sent (modulo,
of course, the cursed trailing whitespace).

thanks
-john

