From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Jan 2005 21:23:48 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02B4B07D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>1) almost all nodes get some SBEs once in a while. Over time these
>accumulate in the directory. We don't consider this to be a problem.
>Gamma rays do happen and if you have a big enough target and 
>you sample for a long enough time, you are bound to catch a few.

<nitpick>The bit flips are more likely the result of neutrons than
gamma rays ... though the neutrons in question were produced by "cosmic"
rays hitting the upper atmosphere.</nitpick>

>Do other people consider 1SBE/hr on a DIMM a real problem that needs to
>be fixed?

That's way too high for background neutrons.  Possibly a DIMM that
got zapped by a static discharge sometime in its life?  Or just a
manufacturing defect small enough to get past the normal testing
process?

Whether it is a problem depends on the liklihood of it cascading into
a multi-bit error ... for which I don't have any data.

-Tony
