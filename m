From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 12 Jan 2005 06:08:56 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02B4B516@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The design of salinfo_decode2 is completely unacceptable for SGI
>hardware, and probably for HP as well.  You have removed all processing
>of the oemdata.
>
>SGI hardware decodes the oemdata in SAL records using prom code.  This
>decode _must_ be done while the record is still in the prom's memory
>space.  The callback into the prom (via the kernel) must be done after
>the main part of the record is printed and before the record is cleared
>from SAL.  For some error types such as CPE, the SGI oemdata provides
>critical information about which DIMM is failing, including its node
>and serial number.

I think that Ben was just plugging the "salinfo_decode2" program that is
included in his alternate salinfo package (though this would perhaps have
been more clear if he'd just posted the program, rather than the whole
package).  The text of his e-mail only talked about salinfo_decode2.

The salinfo_decode2 program just takes the 'raw' images of error records
that have been saved by any daemon, and creates summary reports.

Thanks for clarifying why his daemon won't work for SGI.

-Tony
