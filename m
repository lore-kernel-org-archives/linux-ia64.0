From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 04 Mar 2004 17:16:23 +0000
Subject: Re: [PATCH] more robust halt_light
Message-Id: <20040304171623.GA9782@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 03, 2004 at 06:40:41PM -0800, Seth, Rohit wrote:
> As far as latency is concerned, do you have any specific workload that
> is getting impacted (severly) by this transition.  

No specific concerns, just vague worry :).

> I think we should remove the compile time CONFIG_OPTION for
> PAL_HALT_LIGHT.  And instead use /proc interface to dynamically
> enable/disable the power transition.

Sure, a sysctl would be fine with me.

Jesse
