From: Tim Cutts <tjrc@sanger.ac.uk>
Date: Fri, 21 Jan 2005 11:34:26 +0000
Subject: Re: glibc-2.3.2 NPTL caveat
Message-Id: <67FE6B74-6BA0-11D9-A318-000A95B2B140@sanger.ac.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16879.19106.549352.469688@napali.hpl.hp.com>
In-Reply-To: <16879.19106.549352.469688@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On 20 Jan 2005, at 6:07 am, David Mosberger wrote:

> We just discovered a nasty bug in glibc-2.3.2 which can lead to
> "random" memory corruption in multi-threaded applications using NPTL.
> This definitely affects Debian/{testing,unstable}, but it may affect
> other distros as well.  I also believe that the CVS glibc still has
> this bug, so I suspect it's not just glibc-2.3.2 that's affected.
>
> For details, see:
>
>   http://sources.redhat.com/bugzilla/show_bug.cgi?idh5

That explains a lot of problems we had with MySQL crashing almost 
instantly on startup on IA64 machines too.  So what needs to be done?  
Is it as simple a fix as always compiling ld-linux with the larger of 
the two thread struct sizes? (he says, extremely naively, since this is 
the sort of thing in Linux that he has no clue about whatsoever - it 
comes under the heading of "scary stuff you leave to Really Clever 
People to think about"  :-)

Tim

-- 
Dr Tim Cutts
Informatics Systems Group, Wellcome Trust Sanger Institute
GPG: 1024D/E3134233 FE3D 6C73 BBD6 726A A3F5  860B 3CDD 3F56 E313 4233

