From: Nathan Scott <nathans@sgi.com>
Date: Mon, 29 Sep 2003 05:52:56 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106481497511564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 17, 2003 at 10:26:25AM -0700, David Mosberger wrote:
> >>>>> On 17 Sep 2003 10:33:47 -0400, Jes Sorensen <jes@wildopensource.com> said:
> 
> >>>>> "Nathan" = Nathan Scott <nathans@sgi.com> writes:
>   Nathan> Does anyone know why the IA64 platform-specific ino_t
>   Nathan> definition is an int and not a long?  Patch below fixes this
>   Nathan> problem for me but I wonder if there will be side-effects I
>   Nathan> haven't considered (i.e. was there a reason for making this
>   Nathan> 32 bits originally?).  If not, could the IA64 maintainers
>   Nathan> push this patch around to the official kernel trees for me?
>   Nathan> (pretty please)
> 
>   Jes> Hi Nathan,
> 
>   Jes> I am actually surprised it's still a 32 bit int in the
>   Jes> kernel. I deliberately used 64 bit types in glibc so it could
>   Jes> be done right. Must have slipped on fixing the kernel for this
>   Jes> one.
> 
>   Jes> David?
> 
> Extending ino_t to 64 bits came up last October [1].  AFAIK, nobody
> bothered to investigate & send a patch, so things didn't change since
> then.
> 
> 	--david
> 
> [1] http://www.gelato.unsw.edu.au/linux-ia64/0210/3952.html
> 

I notice a big batch of IA64 changes has just gone into 2.6-test6,
but this change seems to be missing.  Is it in someones queue for
next time or do I need to describe the problem more clearly?

The investigation and the patch I sent are available here[2].

cheers.

-- 
Nathan

[2] http://www.gelato.unsw.edu.au/linux-ia64/0309/6681.html
