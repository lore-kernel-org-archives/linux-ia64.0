From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Jan 2005 19:03:59 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <16868.8991.676455.65120@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Jan 2005 07:46:28 -0800, Ben Woodard <woodard@redhat.com> said:

  Ben>        salinfo_decode2 also has the capability to generate
  Ben> output that is designed to be easily parsed by a machine. This
  Ben> is useful when you want to automate monitoring of large numbers
  Ben> of machines. For example, instead of having scripts notify you
  Ben> every time an ignorable single bit memory error occurs, the
  Ben> monitoring scripts can easily ignore those errors and only
  Ben> point out higher priority error conditions.

It seems a bit dangerous to me to encourage ignoring single-bit
errors.  Perhaps it would be better to suggest to summarize these
errors?

	--david
