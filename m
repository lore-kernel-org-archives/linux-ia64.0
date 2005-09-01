From: "John Ik Lee \(WA\)" <jlee@platsolns.com>
Date: Thu, 01 Sep 2005 22:14:45 +0000
Subject: RE: Update to Software Developer's Manual
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E018A4BC9@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F042C7BF6@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F042C7BF6@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Could you IPF platform makers share when the new PAL entry
PAL_MC_ERROR_INJECT is going to be available in your platforms?

Thanks,
John Ik Lee (J.I.)
Sr. Staff Engineer
Platform Solutions, Inc

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Christian Hildner
Sent: Thursday, August 18, 2005 11:20 PM
To: Luck, Tony
Cc: linux-ia64@vger.kernel.org
Subject: Re: Update to Software Developer's Manual

Luck, Tony schrieb:

>There is a specification update to the Itanium Architecture
>Software Developer's Manual available at:
>
>http://developer.intel.com/design/itanium/downloads/248699.htm
>
>One new goody is a new PAL call for error injection (which should
>help a lot with testing the MCA paths ... bad news is that you'll
>have to wait for Montecito to see a PAL that implements it).
>
Just for interest. Did anyone already boot Linux on Montecito hardware? 
Are additional patches necessary to do so?

Christian

>-Tony
>
>P.S. Sunglasses may be required for pages 15-17 ... the authors
>of those pages seem to have gone a little wild with their use
>of colour :-)
>
PPS: I wasn't careful enough and even burned my skin ;-).

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
