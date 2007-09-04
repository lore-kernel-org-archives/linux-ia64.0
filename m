From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Sep 2007 09:03:13 +0000
Subject: RE: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to be disabled - take 2
Message-Id: <617E1C2C70743745A92448908E030B2A024F3ECD@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> global cache purge in their chipset implementation. (For such cases, Intel provided a SAL 
>> table entry to specify if ptc.g is allowed and how many).
>
> This seems odd.  You never use that sal call to initialized noptcg.
> Is that an oversight?

The mechanism is a SAL table entry, not a SAL call.  Currently that
entry provides no mechanism to specify that ptc.g should not be used
at all (the entry provides the count of how many ptc.g can happen in
parallel, but the spec says that the value "0" means "1" :-( )

There is an ongoing discussion with DIG64 to use a currently reserved
field in the table to specify the value "0".  If that change is approved,
then we can add code to enable Natalie's code based on the SAL table.

-Tony
