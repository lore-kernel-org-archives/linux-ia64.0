From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 08 Oct 2003 20:51:19 +0000
Subject: Re: [PATCH 2.6.0test5: 2 of 3] MCA/TLB recovery
Message-Id: <marc-linux-ia64-106564655631043@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106522368223247@msgid-missing>
In-Reply-To: <marc-linux-ia64-106522368223247@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 3 Oct 2003 16:27:25 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> This part is just a clean-up of the logging code to only
  Tony> print registers that are implemented (instead of blindly
  Tony> dumping CR[0] ... CR[127] and AR[0] ... AR[127].

  Tony> +/* Bitmasks of implemented registers */
  Tony> +static u64 arbits[2] = { 0x11117f2f00ffUL, 0x7UL };
  Tony> +static u64 crbits[2] = { 0x3fb0107UL, 0x307ffUL };

Shouldn't these masks be obtained from PAL?

  Tony> +static u64 brbits[1] = { 0xffUL };
  Tony> +static u64 rrbits[1] = { 0xffUL };

These look a bit weird to me (since they're architected), but I guess
it's your call...

	--david
