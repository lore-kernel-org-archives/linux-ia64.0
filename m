From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Jan 2005 04:10:15 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <15959.1105503015@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 Jan 2005 07:46:28 -0800, 
Ben Woodard <woodard@redhat.com> wrote:
>Here is a new utility for looking into salinfo records. It several
>things differently than salinfo_decode. We have found that this helps

The design of salinfo_decode2 is completely unacceptable for SGI
hardware, and probably for HP as well.  You have removed all processing
of the oemdata.

SGI hardware decodes the oemdata in SAL records using prom code.  This
decode _must_ be done while the record is still in the prom's memory
space.  The callback into the prom (via the kernel) must be done after
the main part of the record is printed and before the record is cleared
from SAL.  For some error types such as CPE, the SGI oemdata provides
critical information about which DIMM is failing, including its node
and serial number.

AFAIK HP decode their oemdata via a user space program.  Again this is
done after the main part of the record is printed.

To handle both SGI and HP requirements, the existing salinfo_decode
program calls the optional program salinfo_decode_oemdata.  That call
is made at the right point in the read/decode/clear cycle to satisfy
all vendor requirements.  Removing salinfo_decode_oemdata is not an
option.

The existing salinfo_decode program works fine, including decoding oem
data.  I agree that we need a summary tool to merge data from multiple
records together, but there are better ways of doing that, we do not
need to remove the existing salinfo_decode functionality to get a
summary.

Leave salinfo_decode completely alone, especially the oem decoding.
To get a summary, add a new package that monitors the contents of
/var/log/salinfo/decoded, reads new records and summarizes the
contents.  I am quite happy to add a trigger (pipe or socket) from
salinfo_decode to the summary program to indicate when new records
arrive.

Any summary program must be extensible so a vendor can report on data
that is extracted from their oemdata.

BTW, salinfo_decode2 will spin forever on a kernel < 2.6.9-rc4,
including all 2.4 kernels.  Once again, salinfo_decode 0.7 gets this
right.

