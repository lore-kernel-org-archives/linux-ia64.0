From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 15 Mar 2004 21:40:05 +0000
Subject: Re: Compilation problem in arch/ia64/sn/kernel/setup.c
Message-Id: <16470.8885.417466.60123@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002b01c40a55$d5b392f0$39624c0f@india.hp.com>
In-Reply-To: <002b01c40a55$d5b392f0$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 15 Mar 2004 08:59:39 -0800, jbarnes@sgi.com (Jesse Barnes) said:

  Jesse> The patch looks fine, but I wonder if we really need
  Jesse> CONFIG_IA64_MCA anymore, does anyone really want to run
  Jesse> without it?

Good point.  MCA used to be rather big because of all the
decoding-crap, but now that's cleaned up, so perhaps there is no
reason to keep CONFIG_IA64_MCA anymore (even the usual Ski simulator
config has CONFIG_IA64_MCA turned on, even though the supporting
firmware-emulator doesn't really do anything about MCAs at the
moment).

	--david
