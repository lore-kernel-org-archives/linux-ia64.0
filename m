From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 04 Mar 2004 17:17:10 +0000
Subject: Re: [PATCH] more robust halt_light
Message-Id: <20040304171710.GB9782@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1078336640.2480.37.camel@patsy.fc.hp.com>
In-Reply-To: <1078336640.2480.37.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 04, 2004 at 08:47:27AM -0700, Alex Williamson wrote:
> Perhaps sn specific code (maybe sn_setup) could call disable_hlt()
> until you're comfortable leaving it on by default.  Requiring a boot
> time command like option on your platform sounds error prone.

Yeah, that would probably be better than a boot time option.

Jesse
