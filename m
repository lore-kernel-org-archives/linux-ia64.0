From: Dave Jones <davej@redhat.com>
Date: Thu, 12 Oct 2006 18:03:21 +0000
Subject: Re: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061012180321.GD21149@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com> <20061012001139.1fea6ecf.akpm@osdl.org> <20061012175536.GA8497@intel.com>
In-Reply-To: <20061012175536.GA8497@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, Judith Lebzelter <judith@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 12, 2006 at 10:55:36AM -0700, Luck, Tony wrote:

 > P.S. Next layer of the onion is CONFIG_BLK_DEV_AMD74XX ... perhaps
 > that needs to be "depends on X86"?

I sent patches to do that a few months ago.
They were shot down due to the alleged value of compile testing on
architectures which will never run those drivers.

	Dave

-- 
http://www.codemonkey.org.uk
