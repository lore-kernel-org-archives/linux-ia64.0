From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Wed, 31 Mar 2004 06:43:01 +0000
Subject: Re: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <406A6875.7030500@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>What I've noticed using traces (and further an ITP tool) is that for 
>>>each processor the "ia64_monarch_init_handler" is ever called. :-(
>>
>>Are you saying that more than one processor calls
>>ia64_monarch_init_handler()?  If so, I think something
>>is broken.
> 
> 
> Or are you saying that NO processor gets to ia64_monarch_init_handler?

All the processors call the "ia64_monarch_init_handler",
the result is that the same trace appears many times (1 per CPU in fact)
and a kernel oops occurs (I think it is due to a concurrent access
to the same stack without any lock mechanism).

> Just a sanity check ... when you set the ITP breakpoint to catch
> the entry ... you did set it at the *physical* address of this function?

Yes, using Hardware breakpoints. When managing INIT interrupt, SAL calls
the physical address of my function.


