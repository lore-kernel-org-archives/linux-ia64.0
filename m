From: Ben Woodard <woodard@redhat.com>
Date: Tue, 11 Jan 2005 21:12:37 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <1105477957.22104.170.camel@quince.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2005-01-11 at 11:03, David Mosberger wrote:
> >>>>> On Tue, 11 Jan 2005 07:46:28 -0800, Ben Woodard <woodard@redhat.com> said:
> 
>   Ben>        salinfo_decode2 also has the capability to generate
>   Ben> output that is designed to be easily parsed by a machine. This
>   Ben> is useful when you want to automate monitoring of large numbers
>   Ben> of machines. For example, instead of having scripts notify you
>   Ben> every time an ignorable single bit memory error occurs, the
>   Ben> monitoring scripts can easily ignore those errors and only
>   Ben> point out higher priority error conditions.
> 
> It seems a bit dangerous to me to encourage ignoring single-bit
> errors.  Perhaps it would be better to suggest to summarize these
> errors?
> 
> 	--david

Does this sound like better wording to you?

salinfo_decode2 also has the capability to generate output that is
designed to be easily parsed by a machine. This is useful when you want
to automate monitoring of large numbers of machines. For example,
instead of having scripts notify the sysadmin every time an isolated
single bit memory error occurs, the monitoring scripts can be designed
to ignore those isolated errors (but save them for later summary
reporting) and notify the sysadmin only if the rate exceeds a specified
threshold.

-ben


