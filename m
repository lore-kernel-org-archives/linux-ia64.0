From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 17 Apr 2002 18:07:09 +0000
Subject: Re: [Linux-ia64] Re: PAL entry point
Message-Id: <marc-linux-ia64-105590701905474@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christian,

On Wed, Apr 17, 2002 at 07:54:14AM -0700, David Mosberger wrote:
> >>>>> On Wed, 17 Apr 2002 15:09:51 +0200, Christian Hildner <christian.hildner@hob.de> said:
> 
>   Christian> Stephane, David, do you agree making the symbol
>   Christian> pal_entry_point global (included in pal.S)? I would need
>   Christian> access to the PAL routines directly from my program
>   Christian> without using the provided functions.
> 
> I'm not sure that's a good idea.  PAL has very particular constraints
> on the environment in which it can be called in.  Why aren't the
> normal entry points (ia64_pal_call_static(), ia64_pal_call_stacked(),
> ia64_pal_call_phys_static(), and ia64_pal_call_phys_stacked())
> sufficient?

I don't think it is a good idea because by itself knowing the entry
point value does not allow you to simply call it. If you look
at pal.S, you see that there is much more involved in calling
a PAL procedure, especially for those labeled physical/static.
So I agree with David, that we should instead export the 4 call
stubs that will allow you (with less effort) to call PAL.

-- 
-Stephane

