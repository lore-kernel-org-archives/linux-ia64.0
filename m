From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Aug 2004 17:12:37 +0000
Subject: RE: Long Format VHPT patches
Message-Id: <200408251712.i7PHCbY31390@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, August 24, 2004 7:34 pm, Ian Wienand wrote:
> 11-lf-VHPT-kconfig.patch

Jesse Barnes wrote on Wednesday, August 25, 2004 10:02 AM
> Given your conclusions in the paper, would it make sense to unconditionally
> switch to long format VHPT?  It would simplify things a little and maybe
> avoid some trouble in the future.

The benchmarks done in the paper are very limited in my opinion, I don't
think it covers the whole spectrum of usage model.  Our internal evaluation
shows otherwise (i.e., LVHPT are slower in some industry benchmarks).  My
point is switching unconditionally so early is probably not a wise idea.

- Ken


