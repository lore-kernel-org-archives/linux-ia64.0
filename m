From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 14 May 2003 20:49:18 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
Message-Id: <marc-linux-ia64-105590723705808@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Williamson <alex_williamson@hp.com> writes:

Alex>    Why not just make a runtime strcmp to platform_name?  Then
Alex> you could make a generic is_platform("sn2") type function/macro
Alex> that everyone could use and you'd get rid of that nasty init
Alex> function.  If you realy need to make such a check in a perfmance
Alex> path, it should probably be a machvec.  Thanks,

Hi Alex,

I think the main reason for this was to cache the strcmp result in an
integer to make it faster.

Cheers,
Jes

