From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 04 Mar 2005 19:28:00 +0000
Subject: RE: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03037BBD@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I've started running multiple copies of checker with the error injection
>code and so far none have indicated any errors on Altix systems.

That's a promising start.  Which errors are you injecting ... I saw the
"f6" problem on a TLB error (which could well have been detected and
reported in the context of the checker program).

If you are still doing 2xECC memory errors, then they'll either be in
the context of some other process, which will be killed.  Or if you
are in the context of one of the "checker" programs, it will be killed
before it can see whether all the registers had the right value. So
this might not be telling us much.

>> Attached (untested) patch does that (not paticularly elegantly, but
>> should be functional).
>
>When I try that patch, the system wedges in the MCA code (on Altix).

:-(   Well I'll wait for Keith to do it properly with pt_regs etc.

-Tony
