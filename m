From: Jack Steiner <steiner@sgi.com>
Date: Wed, 28 Feb 2001 17:05:07 +0000
Subject: RE: Re: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005223@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005190@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005190@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Thanks for investigating the problem and the patch. The problem is happening
> because the timeout (40000UL) is not long enough. The processor is taking
> long time than this to complete the handle_IPI and processor doing the
> flush_tlb_no_ptcg is timing out and sending the IPI again. So, we should
> increase the timeout rather than decreasing the timeout to avoid extra
> reschedule IPIs.

I wondered about the timeout too. I agree that we do not want to go thru
the resend_IPI code very often. I planned to add some stats to see
how often the resend occurred & also whether any IPIs were really being
dropped.

Is the code to resend IPIs going to remain OR is it just to workaround 
an earlier sighting (#117) that reported IPIs being dropped?? If the resend
is permanent, then the "reschedule IPI" hack needs to be changed to something
more like a null IPI. If the resend is temporary, then just increasing
the timeout seems fine.



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


