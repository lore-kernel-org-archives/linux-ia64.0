From: Francois Wellenreiter <Francois.Wellenreiter@Ext.Bull.Net>
Date: Thu, 01 Apr 2004 06:26:59 +0000
Subject: Re: Abnormal behaviour towards "INIT" interrupt management
Message-Id: <406BB633.9080804@Ext.Bull.Net>
List-Id: <linux-ia64.vger.kernel.org>
References: <40691B80.9070309@Ext.Bull.Net>
In-Reply-To: <40691B80.9070309@Ext.Bull.Net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 
>>All the processors call the "ia64_monarch_init_handler",
>>the result is that the same trace appears many times (1 per CPU in fact)
>>and a kernel oops occurs (I think it is due to a concurrent access
>>to the same stack without any lock mechanism).
> 
> 
> What kind of machine is this?  

I've done my tests first on Tiger4 (with a SAL version 3.00)
and after on a Bull NOvaScale 5160.
These tests went to the same results...

> Linux registers different OS_INIT
> procedures for the monarch and non-monarch processors, so it
> sounds like a SAL bug if more than one CPU calls
> ia64_monarch_init_handler().

That's what I fear.



		Francois WELLENREITER

