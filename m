From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 28 Feb 2001 17:56:13 +0000
Subject: RE: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005224@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Is the code to resend IPIs going to remain OR is it just to 
> workaround 
> an earlier sighting (#117) that reported IPIs being dropped?? 
> If the resend
> is permanent, then the "reschedule IPI" hack needs to be 
> changed to something
> more like a null IPI. If the resend is temporary, then just increasing
> the timeout seems fine.

This is a workaround and is not needed for B3 and later steppings.

Thanks,
Asit

Thanks,
Asit


