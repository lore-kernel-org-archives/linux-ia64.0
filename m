From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Thu, 06 Mar 2008 10:24:06 +0000
Subject: Re: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47CFC646.2070402@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:

> That is not nearly enough.  On a large shared memory system multiple
> CPUs can hit the same memory error at the same time (for example).
> There are several test cases in my test environment that cause
> multiple CPUs to go into MCA at the same time.  The value needs 
> to scale with system size.

These are the consequences of the same bad memory block.
There is no more information about the health of the machine in
N log instances of the same memory error, than in the first one.
Anyway, the HW guys or the maintenance guys will count the events
as a single occurrence of memory failure.

> What happens on boot up, when salinfo reads all the old records?
> Does that "burst" of records all get logged.

The errors coming from the events before the reboot do not go
through the MCA handler. The salinfo side reads them directly by
calling ia64_sal_get_state_info().

>>The probability to have more than that _independent_ events
>>in a small time frame is very very low. Therefore you can
>>afford losing events of the same "burst".
> 
> Large systems turn unlikely probabilities into likely.

A rough estimation can be done as follows:

Assume you have an MTBF of 30,000 hours.
The probability of having an MCA in a one minute time frame is less
than 1 / (60 * 30,000) < 10^(-6).
The probability of having two independent errors causing MCAs in
the same one minute time frame is less than 10^(-12).

> That FIXME was to work around a case where all the CPUs rendezvoued but SAL
> did not identify any of the CPUs as monarch.

I agree, I just wanted to mention that it is not sure that the SALs
fully respect the specification. In addition, it is allowed that a
a rendezvous be unsuccessful.

I designed my code not to reckon on successful rendezvous.

> I have a test case that creates that scenario.  With your patch and only 
> one of the MCAs (at most) end up getting logged in /var/log/salinfo/decoded .

Can you describe, please, what your test does and what is the
expected behavior of the MCA layer?

Another idea: the integration into the salinfo side in not yet quit smooth, :-)
it is the polling that fetches the logs one by one. Please leave 3 periods
for the polling to see all the logs.

Thanks,

Zoltan





