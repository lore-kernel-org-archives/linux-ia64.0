From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Tue, 11 Jan 2005 21:36:52 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <200501112136.j0BLarfD002696@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Ben> We believed rates of SBEs in the neighborhood of 1/hr would
>   Ben> ultimately lead to MBEs but further testing has shown that we
>   Ben> really don't see DIMMS with SBEs turing in MBEs.
> 
> That's very interesting.

We have seen both : hard SBEs which never end up in a UCE and bursts of
SBEs which will lead to UCEs. It is DRAM vendor specific and it depends
in which phase of the chips life cycle the error occurs (infant mortality
or not). 

Another important data point is if the error is "soft", i.e. after a scrub
operation it's corrected (probably caused by an alpha particle hit) or
"hard", i.e. the error still is there after the memory location has been
re-written.

I think as long as it is possible to log all errors, the following toolchain
can be adopted. Depending on the system infrastructure it might be useful
to capture additional information such as :
  
  - data pattern including ECC
  - environmental conditions (voltage, temperature)
  - DIMM serial numbers

The later is becoming a real issue when dealing with systems which have
several tera-bytes of main memory, but as I said this really is very 
platform specific


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

