From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 27 Oct 2003 16:58:08 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106727468932261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

my name is Matthias Fouquet-Lapar, I'm working in SGI's 
SW platform group mainly on CPU exception and error handling.

As other members of this group, we're also looking into
changing the Linux error handling to suit the needs of
a reliable super-computer environment.

I think error handling needs to be extended to not only
recover from errors and kill for example the concerned
application. Increasing chip density will increase the
soft error rate, so it also becomes important to determinate
if a error is soft (caused for example by cosmic rays)
or if it is a true HW component failure requiring a
replacement.

There are also more complex error scenarios in multiple
CPU environments when for example all CPUs access a cache
line which has an error.

Traditionally we're verifying our error handling by
error injection as well as running tests with real, broken
HW components for verification and regression testing.

Obviously a lot of the error handling will be very
platform dependant, but I think we should be able to come up
with a common frame set. What do you think ?


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127




> I want to make contributions to the development of MCA Error Handling.
> 
> According to IPF Error Handling Guide, OS should have capability to recover from
> error.
> 
> There are three types of error, Corrected, Recoverable, and Fatal. They are
> reported to OS by MCA/CPEI/CMCI, and actions required to OS depend on the type
> of them. Relations between the type and the action are as follows;
> 
>  - Corrected:
>      Do nothing.
> 
>  - Recoverable:
>      Depends on the situation,
>      - Fix the error, continue interrupted thread.
>      - Terminate suffered threads.
>      - Just as Fatal, reboot.
> 
>  - Fatal:
>      Reboot system immediately.
> 
> In all case, Linux should log error information based on SAL record.
> So, some programs in user land, like fault prediction logic or
> a daemon that reports error to remote site, could use these logs. And
> system administrator also could use these logs to keep their system
> healthy.
> 
> 
> I have strong expectations for Linux to realize such recovery features.
> However, Linux is deficient in recovery codes, especially on recoverable MCA,
> at this moment. (I know your good job, Tony.)
> 
> I want to know what difficulty keep Linux as-is.
> 
> What do you think of error recovery on Linux?
> What kind of functions, macros, structures should Linux have for recovery?
> 
> 
> Best regards,
> 
> ------
> 
> H.Seto <seto.hidetoshi@jp.fujitsu.com>
