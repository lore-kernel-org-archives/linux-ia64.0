From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 13 Jun 2005 21:44:03 +0000
Subject: Re: ia64: Add cpu cache flush to offlining cpu
Message-Id: <17069.65059.392749.345973@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050613142355.A4152@unix-os.sc.intel.com>
In-Reply-To: <20050613142355.A4152@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 13 Jun 2005 14:23:55 -0700, Ashok Raj <ashok.raj@intel.com> said:

  Ashok> +#define FLUSH_INSTR_CACHE		(1UL)
  Ashok> +#define FLUSH_DATA_CACHE		(2UL)
  Ashok> +#define FLUSH_INST_DATA_CACHE	(3UL)
  Ashok> +#define MAKE_INST_DATA_COHERENT	(4UL)

How about using a "SAL_" prefix for these (customary and given the
generic nature of these names, it's quite likely that sooner or later
the unprefixed names would cause a collision with other kernel
headers).

	--david
