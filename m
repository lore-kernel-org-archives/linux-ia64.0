From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 04 Mar 2004 02:48:31 +0000
Subject: RE: [PATCH] more robust halt_light
Message-Id: <01EF044AAEE12F4BAAD955CB75064943010F0900@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



>-----Original Message-----
>From: Grant Grundler [mailto:iod00d@hp.com]
>Sent: Wednesday, March 03, 2004 3:35 PM
>To: Alex Williamson
>Cc: Seth, Rohit; linux-ia64
>Subject: Re: [PATCH] more robust halt_light
>
>On Wed, Mar 03, 2004 at 02:08:00PM -0700, Alex Williamson wrote:
>>
>>    I was curious about that myself, but I thought I remembered from
>> Stephane that the perf counters didn't really recover from a
>> PAL_HALT_LIGHT on McKinley.
>
>The way I recall Stephane explaining it to me was the PMU
>was completely disabled after returning from PAL_HALT_LIGHT.
>ISTR no PAL fix was never released for Mckinley. And even if
>one was, we'd have to convince HP firmware teams to roll
>and qualify it. Unlikely.

In the new scheme that we are proposing, the PMUs are disabled at the
time of entry to PAL_HALT_LIGHT.  They will stay that way after
returning from PAL call.

