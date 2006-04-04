From: Dean Nelson <dcn@sgi.com>
Date: Tue, 04 Apr 2006 15:29:17 +0000
Subject: Re: [PATCH] eliminate compiler warning for xpc_channel.c
Message-Id: <20060404152917.GA30014@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
In-Reply-To: <44327C95.mailxM9N11TC7P@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 04, 2006 at 07:34:08AM -0700, Luck, Tony wrote:
> >> Did you mean to say "*msg = NULL"?
> >
> > this is actually an ANSI-permitted idiom for shutting up compiler
> > warnings while not actually initialising the variable.
> 
> So I learned something new today!
> 
> But then this patch is wrong ... it shuts the compiler up
> and leaves 4 ways that xpc_allocate_msg() can return without doing
> the initialization, so that msg will be used uninitialized.

You are correct: "*msg = NULL" is the right answer.

The compiler being used is: "gcc (GCC) 4.1.0 (SUSE Linux)".

In the past when I've seen complier warnings of this nature, it usually
(but not always) turned out that the compiler was unable to 'see' that
things were really okay. In this particular case, I hadn't seen this
warning until just yesterday (my build machine was just updated a few
days ago), and since nothing in this area of the code had changed for
some time now, I just assumed that the compiler was not seeing things
properly. It didn't occur to me that xpc_allocate_msg() was possibly
being inlined and thus the compiler was giving a correct warning that
should not be ignored.

Do you want a new patch, or are you comfortable with switching the
'msg' to a 'NULL'?

Thanks for looking more closely than I obviously did.

Dean

