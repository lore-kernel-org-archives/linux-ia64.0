From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 11 Jan 2005 20:53:56 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <Pine.LNX.4.61.0501120740430.8213@woolami.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 11 Jan 2005, Ben Woodard wrote:
> ...
> 3) If there is a real failure, it shows up really quickly. We have all
> sorts of SBEs or MBEs. In that case we replace the DIMM immediately.
>
> So does anyone with "normal world" experience have any suggestions on
> how I should take into account the various perspectives?
>
> Do other people consider the isolated SBE a problem?

considered normal, fully recoverable.

>
> Do other people consider 1SBE/hr on a DIMM a real problem that needs to
> be fixed?

this is a concern if the failing DIMM ends up with uncorrectable MBEs.
Do you have any evidence that a relatively high rate of SBEs on a
DIMM can be used to predict that MBEs are likely to start occurring?
Memory hot-unplug or a bad-page reserving strategy based on such
prediction may be interesting.

-- Mark
