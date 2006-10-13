From: Judith Lebzelter <judith@osdl.org>
Date: Fri, 13 Oct 2006 17:47:14 +0000
Subject: Re: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061013174714.GA822@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AA634B8@scsmsx411.amr.corp.intel.com> <20061012001139.1fea6ecf.akpm@osdl.org> <20061012175536.GA8497@intel.com> <20061012123714.85ab4ebb.akpm@osdl.org> <20061012210033.GA9669@intel.com>
In-Reply-To: <20061012210033.GA9669@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, Judith Lebzelter <judith@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 12, 2006 at 02:00:33PM -0700, Luck, Tony wrote:
> [IA64] Fix allmodconfig build
> 
> The HP_SIMSCSI driver can't be built as a module (unhealthy
> dependencies on things that shouldn't really be exported).
> 
> AMD and nVidia IDE support doesn't sound too useful for ia64
> either :-)

Thanks for doing this.  I run cross compiles and do not always 
know what is the best fix for the architecture.  I have been trying
to address some of these errors so that the compiles for 'allmodconfig' 
will be less 'noisy' and easier to get value out of. 

Judith

