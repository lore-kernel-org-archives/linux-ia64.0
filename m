From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 04 Feb 2005 09:33:03 +0000
Subject: Re: ia64 uaccess changes?
Message-Id: <1107509583.2555.51.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2005-02-04 at 17:37, Andrew Morton wrote:
> Did something changed with the ia64 uaccess functions a few weeks ago?
> 
> Because a couple of weeks ago I was seeing repeatable oopses in
> Linus's
> tree early in boot in create_elf_tables(), here:
> 
>         /* Now, let's put argc (and argv, envp if appropriate) on the
> stack */
>         if (__put_user(argc, sp++))
>                 return -EFAULT;
> 
> that shouldn't happen.
> 
> 
> Now, Linus's tree works OK, but I'm seeing repeatable oopses late in
> boot
> with this patch applied: 
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.11-rc2/2.6.11-rc2-mm2/broken-out/add-do_proc_doulonglongvec_minmax-to-sysctl-functions.patch
> 
> which is crazy - that code isn't even executed.
> 

Hi Andrew,

I have tested both 2.6.11-rc3 and 2.6.11-rc2-mm2 on a Tiger.

They all boot fine.


Zou Nan hai
 

