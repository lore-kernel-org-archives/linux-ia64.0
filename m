From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Jan 2005 20:25:04 +0000
Subject: RE: new utility for decoding salinfo records
Message-Id: <16868.13856.288433.196327@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 11 Jan 2005 11:49:52 -0800, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> For this system you really wouldn't want to wake your system
  Tony> admins for every single bit error that was reported

Of course not.

  Tony> (though summarizing the errors in a weekly/monthly report
  Tony> would of course be a good thing).  I believe that
  Tony> salinfo_decode2 makes doing this easy too.

Yes.  While individual single-bit errors aren't terribly interesting,
periodic summaries almost certainly would be.  If only so you know
when to order replacement DIMMs... ;-)

	--david
