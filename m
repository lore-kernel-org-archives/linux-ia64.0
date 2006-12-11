From: Fenghua Yu <fenghua.yu@intel.com>
Date: Mon, 11 Dec 2006 17:54:58 +0000
Subject: Re: [PATCH 5/5] Itanium MC Error Injection Tool: pal_mc_error_inject() interface
Message-Id: <20061211175458.GA9731@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161731.A1106@unix-os.sc.intel.com>
In-Reply-To: <20061208161731.A1106@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 11, 2006 at 10:02:52AM +1100, Keith Owens wrote:
> > 
> >+#define PAL_MC_ERROR_INJECT	276	/* Injects processor error or returns injection capabilities */
> 
> Does this need a particular version of PAL?
Yes, the latest Montecito PAL supports this feature. Please note because of errata in PAL, some errors
can not be injected correctly. Please see patch [2/5] for tested working errors.
