From: "John Lee" <jlee@platsolns.com>
Date: Wed, 09 Feb 2005 22:25:29 +0000
Subject: RE: What contributes to IA64 ITC/TOD drift?
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E01120F69@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <AEBB9AF2F7713A4FAB1397435451162E01120E12@spock.invent.psi.com>
In-Reply-To: <AEBB9AF2F7713A4FAB1397435451162E01120E12@spock.invent.psi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks David,

More specifically I'm concerned about ITC/TOD on MCA, PMI, PM, or such
platform behaviors.
Is there any chance that these platform behaviors affect ITC/TOD?
Spec says ITC is unchanged by [SP]AL's MCA|PMI handling and continue to
clock. Does this mean it assures no ITC drift?
If no drift among ITCs, they all still can be equally wrong or off after
the events which mandates TOD recalibration?

> From: David Mosberger [mailto:davidm@napali.hpl.hp.com] 
> >>>>> On Tue, 8 Feb 2005 18:27:01 -0800, "John Lee" 
> <jlee@platsolns.com> said:
> 
>   John> Maybe too broad a question but,
> 
>   John> 1. What in IA64 platform contributes to ITC drift?
> 
> Are you asking when the IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT bit should
> be set?  If so, then the answer is that it should be set whenever the
> ITC clocks of the processors in a machine are not driven off the same
> oscillator.

Yes, I read that in SAL spec update. That should mean that single
oscillator ensures no drift among ITCs.

> 
>   John> 2. What in IA64 platform contributes to TOD fluctuation?
>   John> (excluding the quality of oscillator)
> 
> NTP comes to mind.  Any other error I can think of probably would lead
> to a systematic error, not to fluctuations.

NTP is for calibration when system TOD is off. What causes TOD off? The
above events - MCA, PMI, or such - can affect TOD?

Thanks,
Jung-Ik Lee
Platform Solutions Inc.
