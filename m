From: Ben Woodard <woodard@redhat.com>
Date: Wed, 12 Jan 2005 16:57:36 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <1105549056.24456.74.camel@quince.llnl.gov>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith, 

I beg to differ with you it is obvious from your post that you didn't
even look at what I sent. You were so spring loaded with your attack on
salinfod (something that I did not send along) that you failed to
actually look at what I produced. In my opinion, that is somewhat
unprofessional.

On Tue, 2005-01-11 at 20:10, Keith Owens wrote:
> On Tue, 11 Jan 2005 07:46:28 -0800, 
> Ben Woodard <woodard@redhat.com> wrote:
> >Here is a new utility for looking into salinfo records. It several
> >things differently than salinfo_decode. We have found that this helps
> 
> The design of salinfo_decode2 is completely unacceptable for SGI
> hardware, and probably for HP as well.  You have removed all processing
> of the oemdata.
> 
> SGI hardware decodes the oemdata in SAL records using prom code.  This
> decode _must_ be done while the record is still in the prom's memory
> space.  The callback into the prom (via the kernel) must be done after
> the main part of the record is printed and before the record is cleared
> from SAL.  For some error types such as CPE, the SGI oemdata provides
> critical information about which DIMM is failing, including its node
> and serial number.

salinfo_decode2 is a completely offline record processor. It does not
interfere with the read, decode, clear cycle. salinfo_decode2 simply
looks at the records that are left by the salinfo_decode2 daemon in raw
raw directory.

salinfo_decode2 may not be able to examine the oem data, in the man page
I point out that salinfo_decode2 has limitations which salinfo_decode is
able to work around.

> 
> AFAIK HP decode their oemdata via a user space program.  Again this is
> done after the main part of the record is printed.

That may also be true but it does not negate the benefits of giving
system administrators, who often times lack and don't need detailed
understanding of the hardware a tool that allows them to maintain and
monitor their machines effectively. In the man page for salinfo_decode2
clearly states that if you need every possible piece of information, you
should look at the decoded output of salinfo_decode.

> 
> To handle both SGI and HP requirements, the existing salinfo_decode
> program calls the optional program salinfo_decode_oemdata.  That call
> is made at the right point in the read/decode/clear cycle to satisfy
> all vendor requirements.  Removing salinfo_decode_oemdata is not an
> option.
> 
> The existing salinfo_decode program works fine, including decoding oem
> data.  I agree that we need a summary tool to merge data from multiple
> records together, but there are better ways of doing that, we do not
> need to remove the existing salinfo_decode functionality to get a
> summary.
> 

If you had actually looked at what I sent, you would have seen that
there is absolutely no existing salinfo_decode functionality removed.

> Leave salinfo_decode completely alone, especially the oem decoding.
> To get a summary, add a new package that monitors the contents of
> /var/log/salinfo/decoded, reads new records and summarizes the
> contents.  I am quite happy to add a trigger (pipe or socket) from
> salinfo_decode to the summary program to indicate when new records
> arrive.

The only difference between what I did and what you suggest is that I
chose to parse the raw records rather than the decoded records. I
believe that there are valid technical reasons for doing this.

> 
> Any summary program must be extensible so a vendor can report on data
> that is extracted from their oemdata.
> 
> BTW, salinfo_decode2 will spin forever on a kernel < 2.6.9-rc4,
> including all 2.4 kernels.  Once again, salinfo_decode 0.7 gets this
> right.

That is distinctly not true. salinfo_decode2 is an offline reader and
doesn't interact at all with the /proc file system. What you are
thinking about salinfod which is not included in this patch.

-ben

