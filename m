From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Tue, 11 Jan 2005 22:26:06 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <200501112226.j0BMQ6Tt002770@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Matthias> systems which have several tera-bytes of main memory, but
>   Matthias> as I said this really is very platform specific
> 
> Probably so.  Still, I think a very interesting systems paper could be
> written that would spell out at least the basic trends/invariants in
> memory error behavior.  Hint, hint... ;-)

I'm actually working on such a paper. The real challenge, as you already
pointed out, is to collect some longer term data. I hope to have something
ready in the summer time frame as it simply takes time to run experiments.
Some testing can be done in environmental stress test chambers, but then
the total sample size is lower. One tool I'm currently looking at would
try predictive error analysis based on the data collected by salinfo.

Some other idea I want to explore is to allow to send a signal to the process. 
(which isn't straight forward ...)
This obviously would only be interesting for on-line diagnostics. 
It would allow the diagnostic to focus on a failing location and see if an 
error is repeatable, if it's data dependant etc. Maybe this feedback mechanism
can help to develop better testing strategies.

(I actually have a test system which has known problem DIMMs)


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

