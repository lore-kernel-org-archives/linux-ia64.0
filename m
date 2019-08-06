From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 06 Aug 2019 07:58:53 +0000
Subject: Re: [PATCH] ia64:unwind: fix double free for mod->arch.init_unw_table
Message-Id: <20190806075853.GA701@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1565077593-72480-1-git-send-email-chenzefeng2@huawei.com>
In-Reply-To: <1565077593-72480-1-git-send-email-chenzefeng2@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: chenzefeng <chenzefeng2@huawei.com>
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue, Aug 06, 2019 at 03:46:33PM +0800, chenzefeng wrote:
> The function free_module in file kernel/module.c as follow:
> 
> void free_module(struct module *mod) {
> 	......
> 	module_arch_cleanup(mod);
> 	......
> 	module_arch_freeing_init(mod);
> 	......
> }
> 
> Both module_arch_cleanup and module_arch_freeing_init function
> would free the mod->arch.init_unw_table, which cause double free.
> 
> Here, set mod->arch.init_unw_table = NULL after remove the unwind
> table to avoid double free.
> 
> Signed-off-by: chenzefeng <chenzefeng2@huawei.com>
> ---
>  arch/ia64/kernel/module.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
