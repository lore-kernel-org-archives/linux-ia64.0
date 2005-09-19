From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 19 Sep 2005 17:46:26 +0000
Subject: Re: Remove warnings for gcc 4.0 IA64 compilation.
Message-Id: <ed5aea4305091910463a94c3c8@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
In-Reply-To: <17193.2147.591751.129603@berry.gelato.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This issue has been discussed before:

  http://www.gelato.unsw.edu.au/archives/linux-ia64/0507/14541.html

I'm still not sure what the proper solution is.  It sure _feels_ wrong
to me for GCC to issue a warning in that case, but there clearly are
weird corners in the C standard so I'm not sure what the right
solution is.

  --david

On 9/19/05, Luck, Tony <tony.luck@intel.com> wrote:
> 
> >Very odd.  I don't see a warning with the current code (using gcc 3.4).
> >But when I applied this patch, I did get a warning (which is what made
> >me take a closer[1] look at this part).
> 
> Ok.  the definition of the pal_freq_ratio structure uses 32-bit wide
> bitfields that are type u64.  So something changed in gcc between
> 3.4 and 4.0 about how such a declaration is interpreted.
> 
> Anyone know which is right?
> 
> We could change the definition in asm/pal.h to read:
> 
> typedef[1] struct pal_freq_ratio {
>         u32     den;
>         u32     num;
> } itc_ratio, proc_ratio;
> 
> and then both version of gcc would be happy with "%u" (but there
> are a few more spots to change in palinfo.c in addition to the
> change to time.c ... doesn't gcc 4 spit out warnings for line 654
> of palinfo.c args 3, 4, 5, 6, 7, 8?  If not, why not?)
> 
> Is there any reason to prefer bitfields over separate elements here?
> 
> Does the attached patch make gcc 4.0 happy?
> 
> -Tony
> 
> [1] we could kill this typedef while editing here, nobody uses
> the "itc_ratio" and proc_ratio" types.  All places that use this
> just use "struct pal_freq_ratio ...".
> 
> 
> 


-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
