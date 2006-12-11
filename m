From: Russ Anderson <rja@sgi.com>
Date: Mon, 11 Dec 2006 19:44:44 +0000
Subject: Re: [PATCH 5/5] Itanium MC Error Injection Tool: pal_mc_error_inject() interface
Message-Id: <200612111944.kBBJiimt66303445@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061208161731.A1106@unix-os.sc.intel.com>
In-Reply-To: <20061208161731.A1106@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fenghua Yu wrote:
> On Mon, Dec 11, 2006 at 10:02:52AM +1100, Keith Owens wrote:
> > > 
> > >+#define PAL_MC_ERROR_INJECT	276	/* Injects processor error or returns injection capabilities */
> > 
> > Does this need a particular version of PAL?
>
> Yes, the latest Montecito PAL supports this feature.

I assume you mean PAL 8.30.  

>  Please note because of errata in PAL, some errors
> can not be injected correctly. Please see patch [2/5] for tested working errors.

The easy way to tell is the -q (query) option.

On Madison:

piton:~/rja.2619-5 # ./err_injection_tool -q
All capabilities implemented in pal_mc_error_inject:
No capabilities supported.

On Montecito:

cobra:~/rja.2619-5 # ./err_injection_tool -q
All capabilities implemented in pal_mc_error_inject:
For err_sev=0, err_struct=1, struct_hier=2: capabilities 0x100001c12
For err_sev=0, err_struct=1, struct_hier=3: capabilities 0x100001c12
For err_sev=1, err_struct=1, struct_hier=2: capabilities 0x100001c12
For err_sev=1, err_struct=2, struct_hier=2: capabilities 0x100000013
For err_sev=1, err_struct=3, struct_hier=1: capabilities 0x100010007
For err_sev=2, err_struct=1, struct_hier=2: capabilities 0x100001c0a


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
