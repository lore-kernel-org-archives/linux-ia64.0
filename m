From: Ben Woodard <woodard@redhat.com>
Date: Tue, 11 Jan 2005 20:26:17 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <1105475177.22104.113.camel@quince.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-01-11 at 11:49, Luck, Tony wrote:
> >  Ben>        salinfo_decode2 also has the capability to generate
> >  Ben> output that is designed to be easily parsed by a machine. This
> >  Ben> is useful when you want to automate monitoring of large numbers
> >  Ben> of machines. For example, instead of having scripts notify you
> >  Ben> every time an ignorable single bit memory error occurs, the
> >  Ben> monitoring scripts can easily ignore those errors and only
> >  Ben> point out higher priority error conditions.
> >
> >It seems a bit dangerous to me to encourage ignoring single-bit
> >errors.  Perhaps it would be better to suggest to summarize these
> >errors?
> 
> Ben's world view might be a little skewed by his test case :-)
> 
> http://www.californiadigital.com/thunder.shtml
> [web page is out of date in regard to position on the top500 list, it
> was pushed down to #5 in the latest list].
> 
> For this system you really wouldn't want to wake your system
> admins for every single bit error that was reported (though
> summarizing the errors in a weekly/monthly report would of course
> be a good thing).  I believe that salinfo_decode2 makes doing
> this easy too.
> 

Tony is correct about that, I really don't have much experience with
anything except Thunder. Working exclusively on a fairly unique machine
gives one a fairly unique perspective.

What we find here are that: 

1) almost all nodes get some SBEs once in a while. Over time these
accumulate in the directory. We don't consider this to be a problem.
Gamma rays do happnen and if you have a big enough target and you sample
for a long enough time, you are bound to catch a few.

2) A few nodes (0.48% or about .06% of the DIMMs) get around 39-173
SBEs/week. This does not seem to be a problem and the problem doesn't
seem to get worse. We have decided as a policy to accept this reasonably
low rate of SBE errors as "OK". In the worst case, we seem to get about
1 SBE/hr.

3) If there is a real failure, it shows up really quickly. We have all
sorts of SBEs or MBEs. In that case we replace the DIMM immediately.

So does anyone with "normal world" experience have any suggestions on
how I should take into account the various perspectives? 

Do other people consider the isolated SBE a problem? 

Do other people consider 1SBE/hr on a DIMM a real problem that needs to
be fixed?


> -Tony

