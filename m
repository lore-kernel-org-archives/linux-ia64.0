From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Jan 2005 06:43:02 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <22737.1105512182@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 Jan 2005 22:08:56 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>The design of salinfo_decode2 is completely unacceptable for SGI
>>hardware, and probably for HP as well.  You have removed all processing
>>of the oemdata.
>>
>>SGI hardware decodes the oemdata in SAL records using prom code.  This
>>decode _must_ be done while the record is still in the prom's memory
>>space.  The callback into the prom (via the kernel) must be done after
>>the main part of the record is printed and before the record is cleared
>>from SAL.  For some error types such as CPE, the SGI oemdata provides
>>critical information about which DIMM is failing, including its node
>>and serial number.
>
>I think that Ben was just plugging the "salinfo_decode2" program that is
>included in his alternate salinfo package (though this would perhaps
>have
>been more clear if he'd just posted the program, rather than the whole
>package).  The text of his e-mail only talked about salinfo_decode2.
>
>The salinfo_decode2 program just takes the 'raw' images of error records
>that have been saved by any daemon, and creates summary reports.

I wish it was that simple.  The salinfo_decode2 patch also adds a new
program called salinfo_daemon, which replaces salinfo_decode_all.
salinfo_daemon reads a record, clears the record then calls
salinfo_decode or salinfo_decode2.

salinfo_decode2 has absolutely no support for oem data.  Even if
salinfo_daemon calls the existing salinfo_decode program, the record
has already been cleared from memory by salinfo_daemon.  In either
case, it is unacceptable for SGI hardware.

I have seen the version of salinfo_decode2 that is shipping in RHEL4
beta and I can guarantee that it does not run on our hardware.  If
salinfo_decode2 is really just a summary program then the patch is
complete overkill.  Ship a separate summary program and database, in
its own package, making it completely separate from the existing (and
working) salinfo_decode.  As the patch stands, it looks like an attempt
to take over salinfo_decode and to remove existing functionallity.

