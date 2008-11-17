From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 17 Nov 2008 19:52:22 +0000
Subject: Re: [PATCH] Ensure PSR.ac is cleared for early userspace
Message-Id: <4921CB76.9060807@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
In-Reply-To: <200811120135.mAC1ZoSd017352@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>If the hypothesis is that test and development kernels would catch the
>>alignment problems, then there shouldn't be any in the production
>>kernels right?  However, if there _are_ any out there in production
>>don't we want them to become visible?  Even on processors which can
>>handle them it is still better to not have the unaligned acesses in the
>>first place right?
> 
> 
> I was thinking of the case where someone loads a module that has
> not had the benefit of being developed in an environment where all
> the unaligned accesses could be easily seen and removed.  It seems
> (to me) that the user of that system would be happier to have the
> flow of "unaligned access" messages on the console reduced by letting
> the h/w handle the ones that it could.

Ignorance being bliss?

If this module was developed in an environment where the unaligned 
accesses could not be easily seen how does hiding the messages in 
production get them addressed?  Modules being developed in such 
environments would seem to suggest that the messages _should_ be seen in 
production?

rick jones
