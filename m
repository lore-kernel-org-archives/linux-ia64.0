From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Wed, 12 Jan 2005 09:34:37 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <200501120934.j0C9YbsX001436@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> salinfo_decode2 has absolutely no support for oem data.  Even if
> salinfo_daemon calls the existing salinfo_decode program, the record
> has already been cleared from memory by salinfo_daemon.  In either
> case, it is unacceptable for SGI hardware.
> 
> I have seen the version of salinfo_decode2 that is shipping in RHEL4
> beta and I can guarantee that it does not run on our hardware.  If
> salinfo_decode2 is really just a summary program then the patch is
> complete overkill.  Ship a separate summary program and database, in
> its own package, making it completely separate from the existing (and
> working) salinfo_decode.  As the patch stands, it looks like an attempt
> to take over salinfo_decode and to remove existing functionallity.

I want to support Keith's summary. We implemented for example a HW system
dump mechanism which saves the HW state of the system in case of a MCA.
(the HW counterpart of a system dump). We also collect associated salinfo
for the event and _absolutely_ rely on the OEM data.

My initial understanding was that salinfo_decode2 was adding some filtering
option, which would be ok (we simply would not use it). But if critical
data is left out, then it simply does not work on correctly on our HW

What is broken in salinfo_decode requiring a re-implementation ? All sorts
of filtering can be done in post-processing

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

