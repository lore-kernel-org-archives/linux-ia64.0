From: Peter Keilty <peter.keilty@hp.com>
Date: Fri, 27 Apr 2007 16:11:52 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <463220C8.5060408@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>	 <1177621673.12796.121.camel@imap.mvista.com>  <46320ACD.6090704@hp.com>	 <1177688158.12796.125.camel@imap.mvista.com>  <463219CD.5040203@hp.com> <1177688931.12796.130.camel@imap.mvista.com>
In-Reply-To: <1177688931.12796.130.camel@imap.mvista.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Walker <dwalker@mvista.com>
Cc: linux-ia64@vger.kernel.org, John Stultz <johnstul@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

Daniel Walker wrote:

>On Fri, 2007-04-27 at 11:42 -0400, Peter Keilty wrote:
>
>  
>
>>>There is a read(), and a vread() did you modify the slow syscall path to
>>>use the vread()?
>>> 
>>>
>>>      
>>>
>>I miss type, read().
>>    
>>
>
>John mentioned that he thought fsys_mmio_ptr could be held in the vread
>pointer. vread() is used in x86 for vsyscalls. It looks like you've used
>the update_vsyscall() which is also used for vsyscalls. So vread could
>also be used .. Have you considered that at all?
>  
>
No, but yes it can be done, overloading the meaning.
It would need to change in the future if vread was needed.
I have no strong argument against  using it.
Although we may still need the IA64 define, I removed 32bit read mmio and
if that is brought back the fast syscall patch call will need to have a 
field in the
clocksource struct that would indicated that. Waiting on comments about 
that...
John and discuss this awhile back felt it was not needed, may prove wrong.

>Daniel
>
>  
>
