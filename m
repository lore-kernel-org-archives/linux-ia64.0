From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Jan 2005 19:49:52 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02B4AF5F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Ben>        salinfo_decode2 also has the capability to generate
>  Ben> output that is designed to be easily parsed by a machine. This
>  Ben> is useful when you want to automate monitoring of large numbers
>  Ben> of machines. For example, instead of having scripts notify you
>  Ben> every time an ignorable single bit memory error occurs, the
>  Ben> monitoring scripts can easily ignore those errors and only
>  Ben> point out higher priority error conditions.
>
>It seems a bit dangerous to me to encourage ignoring single-bit
>errors.  Perhaps it would be better to suggest to summarize these
>errors?

Ben's world view might be a little skewed by his test case :-)

http://www.californiadigital.com/thunder.shtml
[web page is out of date in regard to position on the top500 list, it
was pushed down to #5 in the latest list].

For this system you really wouldn't want to wake your system
admins for every single bit error that was reported (though
summarizing the errors in a weekly/monthly report would of course
be a good thing).  I believe that salinfo_decode2 makes doing
this easy too.

-Tony
