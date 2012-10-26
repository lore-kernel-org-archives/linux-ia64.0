From: Marcelo Tosatti <mtosatti@redhat.com>
Date: Fri, 26 Oct 2012 20:51:31 +0000
Subject: Re: [PATCH] KVM: ia64: remove unused variable in kvm_release_vm_pages()
Message-Id: <20121026205131.GC4991@amt.cnet>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAPgLHd_Nr6c-odC3OWJg5BYh5GA=iqHbXPJ_6dz6a+N_fH05ow@mail.gmail.com>
In-Reply-To: <CAPgLHd_Nr6c-odC3OWJg5BYh5GA=iqHbXPJ_6dz6a+N_fH05ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: avi@redhat.com, xiantao.zhang@intel.com, tony.luck@intel.com, fenghua.yu@intel.com, yongjun_wei@trendmicro.com.cn, kvm@vger.kernel.org, kvm-ia64@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Oct 17, 2012 at 11:03:42PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable base_gfn is initialized but never used
> otherwise, so remove the unused variable.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  arch/ia64/kvm/kvm-ia64.c | 2 --
>  1 file changed, 2 deletions(-)

Applied, thanks.

